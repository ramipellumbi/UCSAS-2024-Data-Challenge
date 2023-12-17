import '@mantine/core/styles.css';

import { ColorSchemeScript, MantineProvider } from '@mantine/core';
import { theme } from '@/src/theme';
import type { Metadata } from 'next';
import { Providers } from './providers';
import { Navigation } from '@/components';

export const metadata: Metadata = {
  title: 'UCSAS 2024 Gymnastics Data Challenge',
  description: 'UI by Rami Pellumbi',
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <head>
        <ColorSchemeScript />
        <meta
          name="viewport"
          content="minimum-scale=1, initial-scale=1, width=device-width, user-scalable=no"
        />
      </head>
      <body>
        <MantineProvider theme={theme}>
          <Navigation>
            <Providers>{children}</Providers>
          </Navigation>
        </MantineProvider>
      </body>
    </html>
  );
}
