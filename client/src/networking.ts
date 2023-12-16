import axios from 'axios';
import qs from 'qs';

const SERVER_URL = (() => {
  if (!process.env.NEXT_PUBLIC_SERVER_URL) {
    throw new Error('NEXT_PUBLIC_SERVER_URL is not defined');
  }
  return process.env.NEXT_PUBLIC_SERVER_URL;
})();

export function configAxios() {
  axios.defaults.baseURL = SERVER_URL;
  axios.interceptors.request.use(
    async (config) => {
      config.paramsSerializer = {
        serialize: (params) => {
          return qs.stringify(params, {
            arrayFormat: 'repeat',
            indices: false,
          });
        },
      };

      return config;
    },
    (error) => {
      return Promise.reject(error);
    }
  );
}
