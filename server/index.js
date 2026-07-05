require('dotenv').config();
const fs = require('fs');
const path = require('path');
const express = require('express');
const bodyParser = require('body-parser');
const Stripe = require('stripe');
const nodemailer = require('nodemailer');

const app = express();
const port = process.env.PORT || 4242;
const stripe = Stripe(process.env.STRIPE_SECRET_KEY);

app.use(express.static(path.join(__dirname, '..', 'docs')));
app.use(bodyParser.json());

// Endpoint para crear sesión de Checkout
app.post('/create-checkout-session', async (req, res) => {
  const { email } = req.body || {};
  if (!email) return res.status(400).json({ error: 'Email requerido' });
  try {
    const session = await stripe.checkout.sessions.create({
      payment_method_types: ['card'],
      mode: 'payment',
      customer_email: email,
      line_items: [{
        price_data: {
          currency: 'eur',
          product_data: { name: 'HB Key' },
          unit_amount: 700
        },
        quantity: 1
      }],
      success_url: `${process.env.PUBLIC_URL}/success.html?session_id={CHECKOUT_SESSION_ID}`,
      cancel_url: `${process.env.PUBLIC_URL}/`,
    });
    res.json({ url: session.url });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'no se pudo crear la sesión' });
  }
});

// Webhook para procesar pagos completados
app.post('/webhook', bodyParser.raw({ type: 'application/json' }), (req, res) => {
  const sig = req.headers['stripe-signature'];
  let event;
  try {
    event = stripe.webhooks.constructEvent(req.body, sig, process.env.STRIPE_WEBHOOK_SECRET);
  } catch (err) {
    console.error('Webhook signature verification failed.', err.message);
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  if (event.type === 'checkout.session.completed') {
    const session = event.data.object;
    const email = session.customer_details?.email || session.customer_email;
    // Generar key aleatoria
    const key = generateKey();
    // Guardar key
    saveKey({ email, key, sessionId: session.id, createdAt: new Date().toISOString() });
    // Enviar email
    sendKeyEmail(email, key).catch(err => console.error('Error sending email', err));
  }
  res.json({ received: true });
});

function generateKey() {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  let k = '';
  for (let i = 0; i < 24; i++) k += chars.charAt(Math.floor(Math.random() * chars.length));
  return k;
}

function saveKey(record) {
  const file = path.join(__dirname, 'keys.json');
  let arr = [];
  try { arr = JSON.parse(fs.readFileSync(file)); } catch (e) { arr = []; }
  arr.push(record);
  fs.writeFileSync(file, JSON.stringify(arr, null, 2));
}

async function sendKeyEmail(to, key) {
  const transporter = nodemailer.createTransport({
    host: process.env.SMTP_HOST,
    port: parseInt(process.env.SMTP_PORT || '587'),
    secure: false,
    auth: {
      user: process.env.SMTP_USER,
      pass: process.env.SMTP_PASS
    }
  });

  const info = await transporter.sendMail({
    from: process.env.FROM_EMAIL,
    to,
    subject: 'Tu key de HB Hub',
    text: `Gracias por tu compra. Tu key: ${key}`,
    html: `<p>Gracias por tu compra. Tu key:</p><pre>${key}</pre>`
  });
  console.log('Email enviado:', info.messageId);
}

app.listen(port, () => console.log(`Server running on ${port}`));
