import { memo } from 'react';

import { Text } from '@mantine/core';

import styles from './TeamSelectedView.module.css';

type TeamSelectedViewProps = {
  selectedTeam: string[];
};

export const TeamSelectedView = memo(function TeamSelectedView({
  selectedTeam,
}: TeamSelectedViewProps) {
  return (
    <div
      style={{
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        paddingBottom: '20px',
      }}
    >
      <Text size="lg" fw={500}>
        {selectedTeam.length === 5 ? 'Team USA' : 'Select a Team of 5'}
      </Text>
      {selectedTeam.length > 0 && (
        <div style={{ display: 'flex', flexWrap: 'wrap', gap: '10px', marginTop: '20px' }}>
          {selectedTeam.sort().map((member) => (
            <div key={member} className={styles.teamMemberCard}>
              <p style={{ fontWeight: 'bold', margin: 0 }}>{member}</p>
            </div>
          ))}
        </div>
      )}
    </div>
  );
});
