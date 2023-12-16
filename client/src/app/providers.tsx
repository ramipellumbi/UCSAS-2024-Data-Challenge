import { configAxios } from '@/networking';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';

// configure networking for the app with interceptors set up
configAxios();

// create a query client for react-query - allowing us to retrieve from the server nicely
const QUERY_CLIENT = new QueryClient();

export function Providers({ children }: ProviderProps) {
  return <QueryClientProvider client={QUERY_CLIENT}>{children}</QueryClientProvider>;
}

type ProviderProps = {
  children: React.ReactNode;
};
