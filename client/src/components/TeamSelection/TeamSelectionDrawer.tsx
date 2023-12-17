'use client';

import {
  Box,
  Button,
  Checkbox,
  Divider,
  Drawer,
  Text,
  Tooltip,
  useMantineTheme,
} from '@mantine/core';
import { useDisclosure } from '@mantine/hooks';
import { memo, useCallback, useState } from 'react';

const RANDOM_NAMES = [
  'Rami Pellumbi',
  'Abraham C',
  'Chen M',
  'Kayla K',
  'Katie L',
  'Katie S',
].sort();

type TeamSelectionDrawerProps = {
  selectedTeam: string[];
  setSelectedTeam: (team: string[]) => void;
  disclosure: ReturnType<typeof useDisclosure>;
};

export const TeamSelectionDrawer = memo(function TeamSelectionDrawer({
  selectedTeam,
  setSelectedTeam,
  disclosure,
}: TeamSelectionDrawerProps) {
  const theme = useMantineTheme();

  const [opened, { close }] = disclosure;
  const [internalTeamState, setInternalTeamState] = useState<string[]>(selectedTeam);

  const handleBoxClick = useCallback(
    (name: string) => {
      const isSelected = internalTeamState.includes(name);
      if (!isSelected && internalTeamState.length < 5) {
        setInternalTeamState([...internalTeamState, name]);
      } else if (isSelected) {
        setInternalTeamState(internalTeamState.filter((n) => n !== name));
      }
    },
    [internalTeamState, setInternalTeamState]
  );

  const handleSubmission = useCallback(() => {
    setSelectedTeam(internalTeamState);
    close();
  }, [internalTeamState, close, setSelectedTeam]);

  return (
    <Drawer
      opened={opened}
      onClose={close}
      title={selectedTeam.length != 5 ? 'Select a team for consideration' : 'Change team'}
      padding="sm"
      size="sm"
      closeOnClickOutside={false}
      closeOnEscape={false}
      withCloseButton={false}
    >
      {RANDOM_NAMES.map((name, index) => (
        <div key={name}>
          <Box
            style={{
              display: 'flex',
              alignItems: 'center',
              padding: '10px',
              cursor: 'pointer',
              borderRadius: theme.radius.md,
              '&:hover': { backgroundColor: theme.colors.gray[1] },
            }}
            onClick={() => handleBoxClick(name)}
          >
            <Checkbox
              checked={internalTeamState.includes(name)}
              readOnly
              style={{ marginRight: '10px' }}
            />
            <Text
              style={{
                color:
                  internalTeamState.length < 5 || internalTeamState.includes(name)
                    ? 'inherit'
                    : theme.colors.gray[5],
              }}
            >
              {name}
            </Text>
          </Box>
          {index < RANDOM_NAMES.length - 1 && <Divider />}
        </div>
      ))}

      <div style={{ display: 'flex', justifyContent: 'center', marginTop: '15px', gap: '10px' }}>
        <Tooltip label="Close without saving changes" withArrow position="bottom">
          <Button disabled={selectedTeam.length != 5} variant="outline" color="red" onClick={close}>
            Close
          </Button>
        </Tooltip>

        <Tooltip
          label="Submit and save selected team. Must have 5 people selected."
          withArrow
          position="bottom"
        >
          <Button disabled={internalTeamState.length !== 5} onClick={handleSubmission}>
            Submit
          </Button>
        </Tooltip>
      </div>
    </Drawer>
  );
});
