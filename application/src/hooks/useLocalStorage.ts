'use client';

import { Dispatch, SetStateAction, useEffect, useState } from 'react';

export const useLocalStorage = <T>(
  key: string,
  initialValue: T
): [T, Dispatch<SetStateAction<T>>] => {
  const [storedValue, setStoredValue] = useState(() => {
    try {
      // Retrieve from localStorage
      const item = window.localStorage.getItem(key);
      // Parse stored json or if none return initialValue
      return item ? JSON.parse(item) : initialValue;
    } catch (error) {
      // If error also return initialValue
      return initialValue;
    }
  });

  useEffect(() => {
    // Retrieve from localStorage
    const item = window.localStorage.getItem(key);
    if (item) {
      setStoredValue(JSON.parse(item));
    }
  }, [key]);

  const setValue = (value: SetStateAction<T>) => {
    setStoredValue((prev: T) => {
      const valueToStore = value instanceof Function ? value(prev) : value;
      // Save to localStorage
      window.localStorage.setItem(key, JSON.stringify(valueToStore));
      return valueToStore;
    });
  };

  return [storedValue, setValue];
};
