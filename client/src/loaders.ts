import Papa from 'papaparse';

export const loadJSON = async (fileName: string): Promise<any> => {
  const response = await fetch(fileName);
  const data = await response.json();

  return data;
};

export const loadCsv = async (fileName: string): Promise<Papa.ParseResult<any>> => {
  const response = await fetch(fileName);
  const parsed = await response.text();

  return Papa.parse(parsed, {
    header: true,
    dynamicTyping: true,
    skipEmptyLines: true,
  });
};
