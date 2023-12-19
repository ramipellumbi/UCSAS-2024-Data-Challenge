'use client';

import { memo, useCallback, useEffect, useState } from 'react';

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

import { Gender } from '@/constants';
import { loadJSON } from '@/loaders';

type TeamSelectionDrawerProps = {
  gender: Gender;
  selectedTeam: string[];
  setSelectedTeam: (team: string[]) => void;
  disclosure: ReturnType<typeof useDisclosure>;
};

export const TeamSelectionDrawer = memo(function TeamSelectionDrawer({
  gender,
  selectedTeam,
  setSelectedTeam,
  disclosure,
}: TeamSelectionDrawerProps) {
  const theme = useMantineTheme();

  const [opened, { close }] = disclosure;
  const [internalTeamState, setInternalTeamState] = useState<string[]>(selectedTeam);
  const [names, setNames] = useState<string[]>([]);

  useEffect(() => {
    const loadNamesJSON = async () => {
      const json = await loadJSON('usa.json');
      const namesObj = processJSON(json);
      const namesForGender = namesObj[gender];
      setInternalTeamState(selectedTeam);
      setNames(namesForGender);
    };

    loadNamesJSON();
  }, [setNames, gender, selectedTeam]);

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

  function Title({ title }: { title: string }) {
    return (
      <div
        style={{
          display: 'flex',
          flex: 1,
          justifyContent: 'space-between',
          padding: '10px 20px',
          gap: '20px',
          alignItems: 'center',
          backgroundColor: 'white',
        }}
      >
        <Text style={{ fontWeight: 500 }}>{title}</Text>
        <Tooltip label="Close without saving changes" withArrow position="bottom">
          <Button variant="outline" color="red" onClick={close}>
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
    );
  }

  return (
    <Drawer
      opened={opened}
      onClose={close}
      title={
        selectedTeam.length != 5 ? <Title title={'Select Team'} /> : <Title title={'Change Team'} />
      }
      size="sm"
      closeOnClickOutside={false}
      closeOnEscape={false}
      withCloseButton={false}
    >
      <div style={{ overflowY: 'auto', maxHeight: 'calc(100% - 60px)' }}>
        {names.map((name, index) => (
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
            {index < names.length - 1 && <Divider />}
          </div>
        ))}
      </div>
    </Drawer>
  );
});

const processJSON = (json: unknown): { m: string[]; w: string[] } => {
  if (typeof json !== 'object' || json === null) {
    throw new Error('Invalid JSON');
  }

  if (!('m' in json) || !('w' in json)) {
    throw new Error('Invalid JSON');
  }

  const m = json['m'];
  const w = json['w'];

  if (!Array.isArray(m) || !Array.isArray(w)) {
    throw new Error('Invalid JSON');
  }

  return { m, w };
};
