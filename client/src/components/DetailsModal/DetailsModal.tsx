import { Accordion, Box, Group, Modal, Text } from '@mantine/core';
import { ApparatusCard } from '..';
import { Apparatus } from '@/constants';

export function DetailsModal({
  open,
  onClose,
  data,
  teams,
}: {
  open: boolean;
  onClose: () => void;
  data: Data[];
  teams: Data[];
}) {
  return (
    <Modal
      opened={open}
      onClose={onClose}
      title="Simulation Details"
      size="xl"
      style={{ maxWidth: 1000 }}
    >
      <NestedAccordion data={data} teams={teams} />
    </Modal>
  );
}

const NestedAccordion = ({ data, teams }: { data: Data[]; teams: Data[] }) => {
  const processedData = processData(data);

  const teamsByCountry = teams.reduce((acc, { name, country }) => {
    if (!acc[country]) {
      acc[country] = [];
    }
    acc[country].push(name);
    return acc;
  }, Object.create(null));

  return (
    <Accordion multiple>
      {Object.entries(processedData).map(([country, apparatuses]) => (
        <Accordion.Item value={country} key={country}>
          <Accordion.Control>{country}</Accordion.Control>
          <Accordion.Panel>
            {Object.entries(apparatuses).map(([apparatus, names]) => (
              <ApparatusCard
                key={apparatus}
                possibleSelections={names}
                apparatus={apparatus as Apparatus}
                team={teamsByCountry[country]}
                selectedMembers={names}
              />
            ))}
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
