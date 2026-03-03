import { db } from "./db";

export function seedDb() {
  db.serialize(() => {
    db.run("DELETE FROM subscriptions");
    db.run("DELETE FROM users");
    db.run("DELETE FROM families");
    db.run("DELETE FROM categories");

    db.run(
      "INSERT INTO families (id, name, invite_code) VALUES (?, ?, ?)",
      [1, "WG Linz", "A7KQ2"]
    );

    // is_eur: 1 = EUR, 0 = USD
    db.run(
      "INSERT INTO users (id, username, email, password, family_id, is_eur) VALUES (?, ?, ?, ?, ?, ?)",
      [1, "Sigma", "sigma@mail.com", "1234", 1, 1]
    );
    db.run(
      "INSERT INTO users (id, username, email, password, family_id, is_eur) VALUES (?, ?, ?, ?, ?, ?)",
      [2, "Niko", "niko@mail.com", "1234", 1, 0]
    );

    db.run("INSERT INTO categories (id, name, color_hex) VALUES (?, ?, ?)", [1, "Streaming", "#FF00AA"]);
    db.run("INSERT INTO categories (id, name, color_hex) VALUES (?, ?, ?)", [2, "Cloud", "#00AEEF"]);

    // Preise werden in EUR gespeichert (Basiswährung!)
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
      [3, "Azure", 15.0, "monthly", "2026-02-10T00:00:00Z", "2026-03-10T00:00:00Z", 2, 2]
    );

    console.log("✅ Seed inserted");
  });
}