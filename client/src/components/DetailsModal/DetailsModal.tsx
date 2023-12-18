import { Accordion, Box, Group, Modal, Text } from '@mantine/core';

export function DetailsModal({
  open,
  onClose,
  data,
}: {
  open: boolean;
  onClose: () => void;
  data: Data[];
}) {
  return (
    <Modal
      opened={open}
      onClose={onClose}
      title="Simulation Details"
      size="xl"
      style={{ maxWidth: 1000 }}
    >
      <NestedAccordion data={data} />
    </Modal>
  );
}

const NestedAccordion = ({ data }: { data: Data[] }) => {
  const processedData = processData(data);

  return (
    <Accordion multiple>
      {Object.entries(processedData).map(([country, apparatuses]) => (
        <Accordion.Item value={country} key={country}>
          <Accordion.Control>{country}</Accordion.Control>
          <Accordion.Panel>
            <Accordion multiple>
              {Object.entries(apparatuses).map(([apparatus, names]) => (
                <Accordion.Item value={apparatus} key={apparatus}>
                  <Accordion.Control>{apparatus}</Accordion.Control>
                  <Accordion.Panel>
                    <Group>
                      {names.map((name, index) => (
                        <Box
                          key={index}
                          style={{ padding: '5px', '&:hover': { backgroundColor: '#f5f5f5' } }}
                        >
                          <Text fw={500}>{name}</Text>
                        </Box>
                      ))}
                    </Group>
                  </Accordion.Panel>
                </Accordion.Item>
              ))}
            </Accordion>
          </Accordion.Panel>
        </Accordion.Item>
      ))}
    </Accordion>
  );
};

const processData = (data: Data[]) => {
  const result: { [key: string]: { [app: string]: string[] } } = {};
  data.forEach(({ name, country, apparatus }) => {
    if (!result[country]) {
      result[country] = {} as { [app: string]: string[] };
    }
    if (!result[country][apparatus]) {
      result[country][apparatus] = [];
    }
    result[country][apparatus].push(name);
  });

  // sort alphabetically in place the names array
  Object.entries(result).forEach(([country, apparatuses]) => {
    Object.entries(apparatuses).forEach(([apparatus, names]) => {
      result[country][apparatus] = names.sort();
    });
  });
  return result;
};

type Data = { name: string; country: string; apparatus: string };
