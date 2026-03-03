import { Request, Response, NextFunction } from "express";
import axios from "axios";
import { db } from "../db";

let fxCache: { rate: number; fetchedAt: number } | null = null;

async function getEurToUsdRate(): Promise<number> {
  const now = Date.now();
  const ttlMs = 60_000;

  if (fxCache && now - fxCache.fetchedAt < ttlMs) return fxCache.rate;

  const resp = await axios.get("https://api.frankfurter.app/latest?from=EUR&to=USD");
  const rate = resp.data?.rates?.USD;

  if (typeof rate !== "number") throw new Error("FX API returned invalid rate");

  fxCache = { rate, fetchedAt: now };
  return rate;
}

export function currencyMiddleware(req: Request, res: Response, next: NextFunction) {
  const userId = Number(req.params.userId);

  if (!userId || Number.isNaN(userId)) {
    return res.status(400).json({ error: "Invalid userId in URL" });
  }

  db.get("SELECT is_eur FROM users WHERE id = ?", [userId], async (err, row: any) => {
    if (err) return res.status(500).json({ error: "DB error (users)" });
    if (!row) return res.status(404).json({ error: "User not found" });

    const isEur = (row.is_eur ?? 1) === 1;
    (req as any).currency = isEur ? "EUR" : "USD";

    try {
      (req as any).fxRate = isEur ? 1 : await getEurToUsdRate();
      next();
    } catch {
      return res.status(502).json({ error: "FX service failed" });
    }
  });
}