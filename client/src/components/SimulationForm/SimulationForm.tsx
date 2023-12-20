'use client';

import { Dispatch, SetStateAction, useState } from 'react';

import { Box, List, MantineTheme, Paper, Slider, Text, useMantineTheme } from '@mantine/core';
import { IconGripVertical } from '@tabler/icons-react';
import { arrayMove, SortableContainer, SortableElement } from 'react-sortable-hoc';

import { APPARATUSES, Gender } from '@/constants';

type SimulationFormProps = {
  initialValue: number;
  setSlider: Dispatch<SetStateAction<number>>;
  gender: Gender;
};

export function SimulationForm({ initialValue, setSlider, gender }: SimulationFormProps) {
  const theme = useMantineTheme();
  const [simulationCount, setSimulationCount] = useState(initialValue);
  const [items, setItems] = useState<string[]>([
    'Team Event',
    'Individual All Around',
    ...(APPARATUSES[gender] as unknown as string[]),
  ]);

  const onSortEnd = ({ oldIndex, newIndex }: { oldIndex: number; newIndex: number }) => {
    setItems(arrayMove(items, oldIndex, newIndex));
  };

  return (
    <Paper shadow="sm" radius="md" p="lg" style={{ maxWidth: 500, margin: '10px auto' }}>
      <Text size="lg" fw={500} mb="xl">
        Simulation Settings
      </Text>
      <Box mb="md">
        <Slider
          value={simulationCount}
          onChange={setSimulationCount}
          onChangeEnd={setSlider}
          min={1}
          max={100}
          labelAlwaysOn
        />
        <Text mt={5} fw={500} size="md">
          Number of Simulations: <b>{simulationCount}</b>
        </Text>
        <Text mt={5} size="sm" c={'gray'}>
          50 simulations takes about 1 minute.
        </Text>
      </Box>

      <Box mb="md">
        <Text mt={20} size="md" fw={500}>
          Sort the order of medal importance:
        </Text>
        <Text mt={5} mb={5} size="sm" c={'gray'}>
          Higher list items are weighted more heavily in the simulation.
        </Text>
        <SortableList items={items} onSortEnd={onSortEnd} theme={theme} />
      </Box>
    </Paper>
  );
}

// Sortable List Item
type SortableItemProps = {
  value: string;
  theme: MantineTheme;
};
const SortableItem = SortableElement<SortableItemProps>(({ value, theme }: SortableItemProps) => (
  <List.Item
    style={{
      padding: '12px 20px',
      cursor: 'pointer',
      backgroundColor: theme.white,
      border: `1px solid ${theme.colors.gray[2]}`,
      borderRadius: theme.radius.sm,
      boxShadow: '0 1px 3px rgba(0,0,0,0.1)',
      display: 'flex',
      alignItems: 'center',
      marginBottom: '8px',
      '&:hover': {
        backgroundColor: theme.colors.gray[0],
        boxShadow: '0 2px 6px rgba(0,0,0,0.15)',
      },
    }}
  >
    <IconGripVertical size={18} style={{ marginRight: '10px' }} />
    {value}
  </List.Item>
));

// Sortable List Container
type SortableListProps = {
  items: string[];
  theme: MantineTheme;
};
const SortableList = SortableContainer<SortableListProps>(({ items, theme }: SortableListProps) => {
  return (
    <List withPadding spacing="xs">
      {items.map((value, index) => (
        <SortableItem key={`item-${index}`} index={index} value={value} theme={theme} />
      ))}
    </List>
  );
});
