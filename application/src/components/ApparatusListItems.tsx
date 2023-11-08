'use client';

import { Fragment, Dispatch, SetStateAction } from 'react';
import {
  Typography,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  ListItem,
  Grid,
  FormHelperText,
  SelectChangeEvent,
} from '@mui/material';
import { CACHE_KEYS, Gender } from '@src/constants';

type ApparatusListItemProps = {
  apparatus: string;
  assignments: Record<string, Record<string, string[]>>;
  gender: Gender;
  setAssignments: Dispatch<
    SetStateAction<Record<string, Record<string, string[]>> | undefined>
  >;
  selectedTeam: string[];
};

export function ApparatusListItem({
  apparatus,
  assignments,
  gender,
  setAssignments,
  selectedTeam,
}: ApparatusListItemProps) {
  const handleSelectChange = (e: SelectChangeEvent<string[]>) => {
    const value = e.target.value;
    const store = Array.isArray(value) ? value : [value];
    if (store.length > 4) return;

    setAssignments((assignments) => {
      const update = {
        ...assignments,
        [gender]: {
          ...(assignments && assignments[gender]),
          [apparatus]: store,
        },
      };

      window.localStorage.setItem(
        CACHE_KEYS.assignments,
        JSON.stringify(update)
      );

      return update;
    });
  };

  return (
    <Fragment key={apparatus}>
      <ListItem>
        <Grid container alignItems="center" spacing={2}>
          <Grid item xs={12} sm={6}>
            <Typography variant="body1">{`Apparatus: ${apparatus}`}</Typography>
          </Grid>
          <Grid item xs={12} sm={6}>
            <FormControl variant="outlined" margin="normal" fullWidth>
              <InputLabel id={`${apparatus}-label`}>
                Select Competitors
              </InputLabel>
              <Select
                labelId={`${apparatus}-label`}
                multiple
                value={assignments?.[gender]?.[apparatus] ?? []}
                onChange={handleSelectChange}
                label="Select Competitors"
                placeholder="Select..."
              >
                {selectedTeam.map((competitor, index) => (
                  <MenuItem key={index} value={competitor}>
                    {competitor}
                  </MenuItem>
                ))}
              </Select>
              <FormHelperText>Select up to 4 competitors</FormHelperText>
            </FormControl>
          </Grid>
        </Grid>
      </ListItem>
    </Fragment>
  );
}
