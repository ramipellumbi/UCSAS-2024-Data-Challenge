'use client';

import { Dispatch, SetStateAction, useState } from 'react';

import { Box, Paper, Slider, Text } from '@mantine/core';

import { Gender } from '@/constants';

type SimulationFormProps = {
  initialValue: number;
  setSlider: Dispatch<SetStateAction<number>>;
  gender: Gender;
};

export function SimulationForm({ initialValue, setSlider }: SimulationFormProps) {
  const [simulationCount, setSimulationCount] = useState(initialValue);

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
    </Paper>
  );
}
