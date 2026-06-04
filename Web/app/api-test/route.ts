// Test endpoint to check what API URL is actually configured
export async function GET() {
  return Response.json({
    NEXT_PUBLIC_API_BASE_URL: process.env.NEXT_PUBLIC_API_BASE_URL || 'not set',
    NEXT_PUBLIC_API_URL: process.env.NEXT_PUBLIC_API_URL || 'not set',
    NODE_ENV: process.env.NODE_ENV,
    timestamp: new Date().toISOString()
  });
}
