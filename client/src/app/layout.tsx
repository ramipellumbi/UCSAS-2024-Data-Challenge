import '@mantine/core/styles.css';

import type { Metadata } from 'next';

import { ColorSchemeScript, MantineProvider } from '@mantine/core';

import { Providers } from './providers';

import { Navigation } from '@/components';
import { theme } from '@/src/theme';

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
