import express, { Request, Response } from "express";
import cors from "cors";

import { db } from "./db";
import { initDb } from "./dbInit";
import { seedDb } from "./dbSeed";
import { currencyMiddleware } from "./middlewares/currency_middleware";

const app = express();
const port = 3000;

app.use(cors());
app.use(express.json());

initDb();
seedDb();

app.get("/favicon.ico", (req, res) => res.status(204).end());

app.get("/test", (req: Request, res: Response) => {
  res.json({ ok: true });
});

// -----------------------------
// USERS
// -----------------------------

app.get("/users/:userId", (req, res) => {
  const userId = Number(req.params.userId);
  if (!userId || Number.isNaN(userId)) return res.status(400).json({ error: "Invalid userId" });

  db.get(
    "SELECT id, username, email, family_id, is_eur FROM users WHERE id = ?",
    [userId],
    (err, row: any) => {
      if (err) return res.status(500).json({ error: "DB error (get user)" });
      if (!row) return res.status(404).json({ error: "User not found" });
      res.json({
        id: row.id,
        username: row.username,
        email: row.email,
        family_id: row.family_id,
        isEur: (row.is_eur ?? 1) === 1
      });
    }
  );
});

app.put("/users/:userId/currency", (req, res) => {
  const userId = Number(req.params.userId);
  const isEur = !!req.body?.isEur;

  if (!userId || Number.isNaN(userId)) return res.status(400).json({ error: "Invalid userId" });

  db.run(
    "UPDATE users SET is_eur = ? WHERE id = ?",
    [isEur ? 1 : 0, userId],
    function (err) {
      if (err) return res.status(500).json({ error: "DB error (update currency)" });
      if (this.changes === 0) return res.status(404).json({ error: "User not found" });
      res.json({ ok: true, userId, isEur });
    }
  );
});

// -----------------------------
// CATEGORIES 
// -----------------------------

app.get("/categories", (req, res) => {
  db.all("SELECT id, name, color_hex FROM categories ORDER BY name", [], (err, rows) => {
    if (err) return res.status(500).json({ error: "DB error (categories)" });
    res.json(rows);
  });
});

// -----------------------------
// SUBSCRIPTIONS mit CURRENCY-MW (currency wird umgerechnet, je nachdem was man ausgewählt hat (€|$))
// -----------------------------

app.get("/subscriptions/:userId", currencyMiddleware, (req, res) => {
  const userId = Number(req.params.userId);
  const fxRate = (req as any).fxRate ?? 1;
  const currency = (req as any).currency ?? "EUR";

  const sql = `
    SELECT
      s.id, s.title, s.price, s.billing_cycle, s.first_payment_date, s.next_reminder_date,
      s.category_id, c.name AS category_name, c.color_hex AS category_color_hex
    FROM subscriptions s
    JOIN categories c ON c.id = s.category_id
    WHERE s.user_id = ?
    ORDER BY s.title
  `;

  db.all(sql, [userId], (err, rows: any[]) => {
    if (err) return res.status(500).json({ error: "DB error (subscriptions)" });

    const mapped = rows.map(r => ({
      id: r.id,
      title: r.title,
      billing_cycle: r.billing_cycle,
      first_payment_date: r.first_payment_date,
      next_reminder_date: r.next_reminder_date,
      category: { id: r.category_id, name: r.category_name, color_hex: r.category_color_hex },
      currency,
      price: Math.round(Number(r.price) * fxRate * 100) / 100
    }));

    res.json(mapped);
  });
});

// Neue Subscription hinzufügen

app.post("/subscriptions/:userId", currencyMiddleware, (req, res) => {
  const userId = Number(req.params.userId);

  const title = String(req.body?.title ?? "").trim();
  const price = Number(req.body?.price);
  const billing_cycle = String(req.body?.billing_cycle ?? "").trim();
  const first_payment_date = String(req.body?.first_payment_date ?? "").trim();
  const next_reminder_date = String(req.body?.next_reminder_date ?? "").trim();
  const category_id = Number(req.body?.category_id);

  if (!title) return res.status(400).json({ error: "title required" });
  if (!Number.isFinite(price)) return res.status(400).json({ error: "price must be number" });
  if (!billing_cycle) return res.status(400).json({ error: "billing_cycle required" });
  if (!first_payment_date) return res.status(400).json({ error: "first_payment_date required" });
  if (!next_reminder_date) return res.status(400).json({ error: "next_reminder_date required" });
  if (!category_id || Number.isNaN(category_id)) return res.status(400).json({ error: "category_id required" });

  db.run(
    `INSERT INTO subscriptions
     (title, price, billing_cycle, first_payment_date, next_reminder_date, user_id, category_id)
     VALUES (?, ?, ?, ?, ?, ?, ?)`,
    [title, price, billing_cycle, first_payment_date, next_reminder_date, userId, category_id],
    function (err) {
      if (err) return res.status(500).json({ error: "DB error (insert subscription)" });
      res.status(201).json({ id: this.lastID });
    }
  );
});

// Wichtif für 1 bestimmte Subscription eines bestimmten Users wird zurückgegeben.

app.put("/subscriptions/:userId/:subId", currencyMiddleware, (req, res) => {
  const userId = Number(req.params.userId);
  const subId = Number(req.params.subId);

  const title = String(req.body?.title ?? "").trim();
  const price = Number(req.body?.price);
  const billing_cycle = String(req.body?.billing_cycle ?? "").trim();
  const first_payment_date = String(req.body?.first_payment_date ?? "").trim();
  const next_reminder_date = String(req.body?.next_reminder_date ?? "").trim();
  const category_id = Number(req.body?.category_id);

  if (!title) return res.status(400).json({ error: "title required" });
  if (!Number.isFinite(price)) return res.status(400).json({ error: "price must be number" });
  if (!billing_cycle) return res.status(400).json({ error: "billing_cycle required" });
  if (!first_payment_date) return res.status(400).json({ error: "first_payment_date required" });
  if (!next_reminder_date) return res.status(400).json({ error: "next_reminder_date required" });
  if (!category_id || Number.isNaN(category_id)) return res.status(400).json({ error: "category_id required" });

  db.run(
    `UPDATE subscriptions
     SET title=?, price=?, billing_cycle=?, first_payment_date=?, next_reminder_date=?, category_id=?
     WHERE id=? AND user_id=?`,
    [title, price, billing_cycle, first_payment_date, next_reminder_date, category_id, subId, userId],
    function (err) {
      if (err) return res.status(500).json({ error: "DB error (update subscription)" });
      if (this.changes === 0) return res.status(404).json({ error: "Subscription not found" });
      res.json({ ok: true });
    }
  );
});

app.delete("/subscriptions/:userId/:subId", currencyMiddleware, (req, res) => {
  const userId = Number(req.params.userId);
  const subId = Number(req.params.subId);

  db.run(
    "DELETE FROM subscriptions WHERE id = ? AND user_id = ?",
    [subId, userId],
    function (err) {
      if (err) return res.status(500).json({ error: "DB error (delete subscription)" });
      if (this.changes === 0) return res.status(404).json({ error: "Subscription not found" });
      res.json({ ok: true });
    }
  );
});

// -----------------------------
// STATS (currency-aware)
// -----------------------------

// Wichtig für den Main-Screen, hier wird die GESAMTAUSGABE des Users angezeigt

app.get("/stats/:userId/total", currencyMiddleware, (req, res) => {
  const userId = Number(req.params.userId);
  const fxRate = (req as any).fxRate ?? 1;
  const currency = (req as any).currency ?? "EUR";

  db.get("SELECT SUM(price) AS total FROM subscriptions WHERE user_id = ?", [userId], (err, row: any) => {
    if (err) return res.status(500).json({ error: "DB error (stats total)" });

    const totalEur = Number(row?.total ?? 0);
    const total = Math.round(totalEur * fxRate * 100) / 100;

    res.json({ userId, currency, total });
  });
});

// Wichtig für den Analysis-Screen, hier werden alle AUsgaben einer Kategorie 
// zusammengefügt und zurückgegeben.


app.get("/stats/:userId/by-category", currencyMiddleware, (req, res) => {
  const userId = Number(req.params.userId);
  const fxRate = (req as any).fxRate ?? 1;
  const currency = (req as any).currency ?? "EUR";

  const sql = `
    SELECT
      c.id AS category_id,
      c.name AS category_name,
      c.color_hex AS color_hex,
      SUM(s.price) AS sum_eur
    FROM subscriptions s
    JOIN categories c ON c.id = s.category_id
    WHERE s.user_id = ?
    GROUP BY c.id, c.name, c.color_hex
    ORDER BY sum_eur DESC
  `;

  db.all(sql, [userId], (err, rows: any[]) => {
    if (err) return res.status(500).json({ error: "DB error (stats by-category)" });

    const totalEur = rows.reduce((acc, r) => acc + Number(r.sum_eur ?? 0), 0);
    const totalConv = totalEur * fxRate;

    const mapped = rows.map(r => {
      const sum = Number(r.sum_eur ?? 0) * fxRate;
      const percent = totalConv > 0 ? (sum / totalConv) * 100 : 0;
      return {
        category_id: r.category_id,
        category_name: r.category_name,
        color_hex: r.color_hex,
        currency,
        sum: Math.round(sum * 100) / 100,
        percent: Math.round(percent * 10) / 10
      };
    });

    res.json(mapped);
  });
});

app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});