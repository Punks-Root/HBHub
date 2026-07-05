Servidor para procesar pagos con Stripe y enviar la key por email.

1) Configura variables en `server/.env` (copia `.env.example`).

2) Instala dependencias y arranca:

```bash
cd server
npm install
npm run start
```

3) Configura Webhook en Stripe apuntando a `https://TU_DOMINIO/webhook` y pega el `STRIPE_WEBHOOK_SECRET` en `.env`.

Nota: debes usar un servidor con URL pública (ngrok, Render, Vercel, Heroku) para recibir webhooks.
