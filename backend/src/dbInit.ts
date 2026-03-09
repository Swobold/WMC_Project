import { db } from "./db";

export function initDb() {
  db.serialize(() => {
    db.run(`
      CREATE TABLE IF NOT EXISTS families (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        invite_code TEXT NOT NULL UNIQUE
      )
    `);

    db.run(`
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY,
        username TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        family_id INTEGER,
        is_eur INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (family_id) REFERENCES families(id)
      )
    `);
    db.run(`CREATE UNIQUE INDEX IF NOT EXISTS idx_users_username ON users(username)`);

    db.run(`
      CREATE TABLE IF NOT EXISTS categories (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        color_hex TEXT NOT NULL
      )
    `);

    db.run(`
      CREATE TABLE IF NOT EXISTS subscriptions (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        price REAL NOT NULL,
        billing_cycle TEXT NOT NULL,
        first_payment_date TEXT NOT NULL,
        next_reminder_date TEXT NOT NULL,
        user_id INTEGER NOT NULL,
        category_id INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id),
        FOREIGN KEY (category_id) REFERENCES categories(id)
      )
    `);
  });
}