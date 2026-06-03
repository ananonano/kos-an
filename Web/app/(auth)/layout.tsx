export default function AuthLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="min-h-screen bg-gradient-to-br from-[#2D1700] via-[#4A2000] to-[#1F0F00] flex items-center justify-center p-4 relative overflow-hidden">
      {/* Decorative elements */}
      <div className="absolute top-0 right-0 w-96 h-96 bg-[#F4B942]/5 rounded-full blur-3xl"></div>
      <div className="absolute bottom-0 left-0 w-80 h-80 bg-[#A23900]/10 rounded-full blur-3xl"></div>
      <div className="w-full max-w-md relative z-10">{children}</div>
    </div>
  );
}