import express from "express";
import cors from "cors";
import helmet from "helmet";
import morgan from "morgan";
import dotenv from "dotenv";
import rateLimit from "express-rate-limit";
import routes from "./routes";
import { errorHandler, notFound } from "./middleware/error.middleware";
import { pool } from "./config/database";

dotenv.config();

const app = express();
const PORT = process.env.PORT || 5000;

app.use(helmet());

// CORS Configuration
const allowedOrigins = [
  "http://localhost:3000", // Local dev
  "https://kosan-web-670153358279.asia-southeast2.run.app", // Production Web
  process.env.CORS_ORIGIN, // Custom origin from env
].filter(Boolean); // Remove undefined values

app.use(cors({
  origin: (origin, callback) => {
    // Allow requests with no origin (mobile apps, Postman, etc.)
    if (!origin) return callback(null, true);
    
    if (allowedOrigins.includes(origin)) {
      callback(null, true);
    } else {
      console.warn(`CORS blocked request from origin: ${origin}`);
      callback(new Error("Not allowed by CORS"));
    }
  },
  credentials: true,
  methods: ["GET", "POST", "PUT", "DELETE", "PATCH"],
  allowedHeaders: ["Content-Type", "Authorization"],
}));

// Rate limiting disabled for development
// const limiter = rateLimit({
//   windowMs: 15 * 60 * 1000, // 15 minutes
//   max: 1000, // Increased from 100 to 1000 for development
//   message: { success: false, message: "Terlalu banyak request, coba lagi nanti." },
// });
// app.use("/api/", limiter);
app.use(express.json({ limit: "10mb" }));
app.use(express.urlencoded({ extended: true, limit: "10mb" }));
if (process.env.NODE_ENV !== "test") { app.use(morgan("dev")); }

app.get("/health", async (_req, res) => {
  try {
    await pool.query("SELECT 1");
    res.json({ success: true, message: "KosTerpadu API is running", version: "1.0.0", database: "connected", timestamp: new Date().toISOString() });
  } catch {
    res.status(503).json({ success: false, message: "Database connection failed" });
  }
});

app.use("/api", routes);
app.use(notFound);
app.use(errorHandler);

app.listen(PORT, () => {
  console.log("KosTerpadu Backend API running on port " + PORT);
});

export default app;
