require('dotenv').config();
const fs = require('fs');
const path = require('path');
const express = require('express');
const bodyParser = require('body-parser');
const Stripe = require('stripe');
const nodemailer = require('nodemailer');
const fetch = require('node-fetch');

const app = express();
const port = process.env.PORT || 4242;
const stripe = process.env.STRIPE_SECRET_KEY ? Stripe(process.env.STRIPE_SECRET_KEY) : null;

app.use(express.static(path.join(__dirname, '..', 'docs')));
app.use(bodyParser.json());

// --- Stripe endpoints remain if needed but PayPal integration added below ---

// PayPal: crear orden y devolver enlace de aprobación
app.post('/create-paypal-order', async (req, res) => {
  const { email } = req.body || {};
  if (!email) return res.status(400).json({ error: 'Email requerido' });
  try {
    const token = await getPayPalToken();
    const order = await createPayPalOrder(token);
    const approval = order.links.find(l => l.rel === 'approve');
    const orderId = order.id;
    // Guardar compra como creada
    savePurchase({ email, orderId, status: 'CREATED', approvalUrl: approval.href, createdAt: new Date().toISOString() });
    res.json({ url: approval.href });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'no se pudo crear la orden de PayPal' });
  }
});

// PayPal redirect (usuario vuelve tras aprobar)
app.get('/paypal-success', (req, res) => {
  const { token } = req.query; // token is orderID in PayPal
  if (!token) return res.redirect('/');
  // actualizar estado a RETURNED (pendiente verificación / captura manual)
  updatePurchaseStatus(token, 'RETURNED');
  // servir una página simple de agradecimiento
  res.sendFile(path.join(__dirname, '..', 'docs', 'paypal-success.html'));
});

function savePurchase(record) {
  const file = path.join(__dirname, 'purchases.json');
  let arr = [];
  try { arr = JSON.parse(fs.readFileSync(file)); } catch (e) { arr = []; }
  arr.push(record);
  fs.writeFileSync(file, JSON.stringify(arr, null, 2));
}

function updatePurchaseStatus(orderId, status) {
  const file = path.join(__dirname, 'purchases.json');
  let arr = [];
  try { arr = JSON.parse(fs.readFileSync(file)); } catch (e) { arr = []; }
  const idx = arr.findIndex(p => p.orderId === orderId);
  if (idx !== -1) {
    arr[idx].status = status;
    arr[idx].updatedAt = new Date().toISOString();
    fs.writeFileSync(file, JSON.stringify(arr, null, 2));
  }
}

async function getPayPalToken() {
  const client = process.env.PAYPAL_CLIENT_ID;
  const secret = process.env.PAYPAL_SECRET;
  const base = 'https://api-m.sandbox.paypal.com';
  const res = await fetch(`${base}/v1/oauth2/token`, {
    method: 'POST',
    headers: {
      Authorization: 'Basic ' + Buffer.from(`${client}:${secret}`).toString('base64'),
      'Content-Type': 'application/x-www-form-urlencoded'
    },
    body: 'grant_type=client_credentials'
  });
  const data = await res.json();
  if (!data.access_token) throw new Error('No access token from PayPal');
  return data.access_token;
}

async function createPayPalOrder(token) {
  const base = 'https://api-m.sandbox.paypal.com';
  const res = await fetch(`${base}/v2/checkout/orders`, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      intent: 'CAPTURE',
      purchase_units: [{ amount: { currency_code: 'EUR', value: '7.00' } }],
      application_context: {
        return_url: `${process.env.PUBLIC_URL}/paypal-success`,
        cancel_url: `${process.env.PUBLIC_URL}/`
      }
    })
  });
  return res.json();
}

// simple key generator (if needed later)
function generateKey() {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  let k = '';
  for (let i = 0; i < 24; i++) k += chars.charAt(Math.floor(Math.random() * chars.length));
  return k;
}

app.listen(port, () => console.log(`Server running on ${port}`));
