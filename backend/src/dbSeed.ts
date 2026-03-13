import { db } from "./db";

export function seedDb() {
  db.serialize(() => {
    db.run("DELETE FROM subscriptions");
    db.run("DELETE FROM users");
    db.run("DELETE FROM families");
    db.run("DELETE FROM categories");

    db.run(
      "INSERT INTO families (id, name, invite_code) VALUES (?, ?, ?)",
      [1, "Testfamilie Muster", "DEMO99"]
    );

    db.run(
      "INSERT INTO users (id, username, email, password, family_id, is_eur) VALUES (?, ?, ?, ?, ?, ?)",
      [1, "Max Mustermann", "max@mustermann.test", "Test1234", 1, 1]
    );
    db.run(
      "INSERT INTO users (id, username, email, password, family_id, is_eur) VALUES (?, ?, ?, ?, ?, ?)",
      [2, "Simon Legat", "simon@test.demo", "Test1234", 1, 1]
    );

    db.run("INSERT INTO categories (id, name, color_hex) VALUES (?, ?, ?)", [1, "Streaming", "#FFB3D1"]);
    db.run("INSERT INTO categories (id, name, color_hex) VALUES (?, ?, ?)", [2, "Unterhaltung", "#D8C3F5"]);
    db.run("INSERT INTO categories (id, name, color_hex) VALUES (?, ?, ?)", [3, "Produktivität", "#C7EFCF"]);
    db.run("INSERT INTO categories (id, name, color_hex) VALUES (?, ?, ?)", [4, "Musik", "#BDE0FE"]);
    db.run("INSERT INTO categories (id, name, color_hex) VALUES (?, ?, ?)", [5, "Sport", "#FFE5B4"]);

    db.run(
      `INSERT INTO subscriptions
       (id, title, price, billing_cycle, first_payment_date, next_reminder_date, user_id, category_id)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      [1, "Netflix", 12.99, "monthly", "2026-02-01T00:00:00Z", "2026-02-28T00:00:00Z", 1, 1]
    );
    db.run(
      `INSERT INTO subscriptions
       (id, title, price, billing_cycle, first_payment_date, next_reminder_date, user_id, category_id)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      [2, "Disney+", 9.99, "monthly", "2026-02-05T00:00:00Z", "2026-03-05T00:00:00Z", 1, 1]
    );
    db.run(
      `INSERT INTO subscriptions
       (id, title, price, billing_cycle, first_payment_date, next_reminder_date, user_id, category_id)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      [3, "Spotify", 10.99, "monthly", "2026-02-10T00:00:00Z", "2026-03-10T00:00:00Z", 1, 4]
    );

    db.run(
      `INSERT INTO subscriptions
       (id, title, price, billing_cycle, first_payment_date, next_reminder_date, user_id, category_id)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      [4, "YouTube Premium", 11.99, "monthly", "2026-02-15T00:00:00Z", "2026-03-15T00:00:00Z", 2, 1]
    );

    console.log("✅ Seed inserted");
  });
}
