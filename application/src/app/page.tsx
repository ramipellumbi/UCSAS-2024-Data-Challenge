'use client';

import { useState } from 'react';
import {
  Container,
  Typography,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  List,
  ListItemText,
  Paper,
  Box,
  Tabs,
  Tab,
  ListItemIcon,
  Checkbox,
} from '@mui/material';
import { ApparatusListItem } from '@src/components/ApparatusListItems';
import { APPARATUSES, CACHE_KEYS, GENDERS, Gender } from '@src/constants';

const COMPETITORS = {
  m: ['Man 1', 'Man 2', 'Man 3', 'Man 4', 'Man 5', 'Man 6', 'Man 7'],
  w: [
    'Women 1',
    'Women 2',
    'Women 3',
    'Women 4',
    'Women 5',
    'Women 6',
    'Women 7',
  ],
} as const;

export default function AssignTeams() {
  const [gender, setGender] = useState<Gender>(() => {
    const item = window.localStorage.getItem(CACHE_KEYS.gender);
    if (item) {
      return JSON.parse(item);
    }

    return GENDERS.MEN;
  });

  const [selectedTeam, setSelectedTeam] = useState<Record<string, string[]>>(
    () => {
      const item = window.localStorage.getItem(CACHE_KEYS.selectedTeam);
      if (item) {
        return JSON.parse(item);
      }

      return {
        [GENDERS.MEN]: [],
        [GENDERS.WOMEN]: [],
      };
    }
  );

  const [assignments, setAssignments] = useState<
    Record<string, Record<string, string[]>>
  >(() => {
    const item = window.localStorage.getItem(CACHE_KEYS.assignments);
    if (item) {
      return JSON.parse(item);
    }

    return {
      [GENDERS.MEN]: {
        ...APPARATUSES[GENDERS.MEN].reduce((acc, apparatus) => {
          acc[apparatus] = [];

          return acc;
        }, Object.create(null)),
      },
      [GENDERS.WOMEN]: {
        ...APPARATUSES[GENDERS.WOMEN].reduce((acc, apparatus) => {
          acc[apparatus] = [];

          return acc;
        }, Object.create(null)),
      },
    };
  });

  const apparatuses = APPARATUSES[gender];
  const names = COMPETITORS[gender];

  //   useEffect(() => {
  //     if (selectedTeam[gender].length < 5) return;

  //     // remove all selections from the apparatus that are not in the selected team
  //     const updatedSelections = apparatuses.reduce((acc, apparatus) => {
  //       acc[apparatus] = assignments[gender][apparatus].filter((name) =>
  //         selectedTeam[gender].includes(name)
  //       );

  //       return acc;
  //     }, Object.create(null));

  //     setAssignments((assignments) => {
  //       const update = {
  //         ...assignments,
  //         [gender]: updatedSelections,
  //       };

  //       window.localStorage.setItem(
  //         CACHE_KEYS.assignments,
  //         JSON.stringify(update)
  //       );

  //       return update;
  //     });
  //   }, [assignments, apparatuses, selectedTeam, gender]);

  return (
    <Container
      sx={{
        display: 'flex',
        flexDirection: 'column',
        justifyContent: 'center',
        alignItems: 'center',
      }}
    >
      <Box sx={{ borderBottom: 1, borderColor: 'divider', marginBottom: 10 }}>
        <Tabs
          value={gender}
          onChange={(_event: React.SyntheticEvent, newValue: Gender) => {
            setGender(newValue);
            window.localStorage.setItem(
              CACHE_KEYS.gender,
              JSON.stringify(newValue)
            );
          }}
        >
          <Tab label="Men" value={GENDERS.MEN} />
          <Tab label="Women" value={GENDERS.WOMEN} />
        </Tabs>
      </Box>
      <Typography
        variant="h4"
        justifyContent={'center'}
        alignItems={'center'}
        gutterBottom
      >
        Select Team
      </Typography>

      <FormControl variant="outlined" fullWidth margin="normal">
        <InputLabel id="team-label">Select a team of 5</InputLabel>
        <Select
          labelId="team-label"
          multiple
          value={selectedTeam[gender].sort()}
          renderValue={(selected) => selected.join(', ')}
          onChange={(e) => {
            const value = e.target.value;
            const store = Array.isArray(value) ? value : [value];
            if (store.length > 5) return;
            setSelectedTeam((prev) => {
              const update = {
                ...prev,
                [gender]: store,
              };

              window.localStorage.setItem(
                CACHE_KEYS.selectedTeam,
                JSON.stringify(update)
              );

              return update;
            });
          }}
          label="Select a team of 5"
        >
          {names.map((person, index) => (
            <MenuItem key={index} value={person}>
              <ListItemIcon>
                <Checkbox checked={selectedTeam[gender].indexOf(person) > -1} />
              </ListItemIcon>
              <ListItemText primary={person} />
            </MenuItem>
          ))}
        </Select>
      </FormControl>

      <Paper
        elevation={3}
        style={{ padding: '20px', margin: '20px', maxWidth: '600px' }}
      >
        <List>
          {apparatuses.map((apparatus) => (
            <ApparatusListItem
              key={apparatus}
              apparatus={apparatus}
              gender={gender}
              assignments={assignments}
              setAssignments={setAssignments}
              selectedTeam={selectedTeam[gender]}
            />
          ))}
        </List>
      </Paper>
    </Container>
  );
}
