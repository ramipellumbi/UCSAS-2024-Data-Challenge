import "./globals.css";
import NextTopLoader from "nextjs-toploader";
import type { Metadata } from "next";
import Navbar from "./navbar";

export const metadata: Metadata = {
  title: "Gymnastics Paris 2024",
  description: "Analytics",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body className="flex flex-col min-h-screen bg-[#D9F0EE]">
        <NextTopLoader showSpinner={false} height={5} color={"#F9F9F9"} />
        <Navbar />
        <div className="flex-grow-0 mt-[3%]">{children}</div>
      </body>
    </html>
  );
}
