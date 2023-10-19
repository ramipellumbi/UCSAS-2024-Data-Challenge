import React from 'react';
import {
  Typography,
  List,
  ListItem,
  ListItemText,
  Paper,
  Box,
  Chip,
} from '@mui/material';

const colorMap = {
  Gold: '#FFD700',
  Silver: '#C0C0C0',
  Bronze: '#CD7F32',
};

const priorities = {
  Gold: 1,
  Silver: 2,
  Bronze: 3,
};

const MedalDataDisplay = ({
  data,
  type,
}: {
  data: {
    [key: string]: {
      medal: 'Gold' | 'Silver' | 'Bronze';
      name: string;
      country: string;
    }[];
  };
  type: 'team' | 'aa' | string;
}) => {
  const numItems = Object.keys(data).length;

  return (
    <Box
      sx={{
        display: 'flex',
        flexDirection: 'row',
        flexWrap: 'wrap',
        alignItems: 'flex-start',
        gap: 2,
        marginY: 5,
      }}
    >
      <Box display={'flex'} width={'100%'}>
        <Typography variant="h6">
          {type === 'team'
            ? 'Team Medalists'
            : type === 'aa'
            ? 'AA Medalists'
            : `${type} Medalists`}
        </Typography>
      </Box>
      {Object.keys(data).map((year, index) => (
        <Paper
          elevation={3}
          key={index}
          style={{
            padding: '20px',
            width: numItems === 1 ? '100%' : 'calc(33.3333% - 16px)',
          }}
        >
          <List>
            {data[year]
              .sort((a, b) => priorities[a.medal] - priorities[b.medal])
              .map((entry, i) => (
                <ListItem key={i}>
                  <ListItemText
                    primary={
                      type === 'team'
                        ? `Country: ${entry.country}`
                        : type === 'aa'
                        ? `AA: ${entry.name} - ${entry.country}`
                        : `Name: ${entry.name}`
                    }
                  />
                  <Chip
                    label={entry.medal}
                    style={{ backgroundColor: colorMap[entry.medal] }}
                  />
                </ListItem>
              ))}
          </List>
        </Paper>
      ))}
    </Box>
  );
};

export default MedalDataDisplay;
