import type { NextApiRequest, NextApiResponse } from 'next';
import { pool } from '../../lib/db';
import bcrypt from 'bcrypt';
import jwt, { SignOptions } from 'jsonwebtoken';
import dotenv from 'dotenv';
dotenv.config();

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'POST') { res.status(405).end(); return; }
  const { email, password } = req.body;
  if (!email || !password) { res.status(400).json({ message: 'Eksik alan' }); return; }
  const [rows] = await pool.query('SELECT id,password_hash,role FROM users WHERE email = ?', [email]);
  const user = (rows as any[])[0];
  if (!user) { res.status(401).json({ message: 'Geçersiz' }); return; }
  const match = await bcrypt.compare(password, user.password_hash);
  if (!match) { res.status(401).json({ message: 'Geçersiz' }); return; }
  const secret = process.env.JWT_SECRET as jwt.Secret;
  const expiresIn = (process.env.JWT_EXPIRES_IN || '1h') as SignOptions['expiresIn'];
  const token = jwt.sign({ sub: user.id, role: user.role }, secret, { expiresIn });
  res.status(200).json({ token, role: user.role });
}
