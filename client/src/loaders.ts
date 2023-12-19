export const loadJSON = async (fileName: string): Promise<unknown> => {
  const response = await fetch(fileName);
  const data = await response.json();

  return data;
};
