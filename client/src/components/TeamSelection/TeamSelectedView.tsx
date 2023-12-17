import styles from './TeamSelectedView.module.css'; // Adjust the path according to your file structure

import { memo } from 'react';

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
      {selectedTeam.length > 0 && (
        <div style={{ display: 'flex', flexWrap: 'wrap', gap: '10px', marginTop: '20px' }}>
          {selectedTeam.map((member) => (
            <div key={member} className={styles.teamMemberCard}>
              <p style={{ fontWeight: 'bold', margin: 0 }}>{member}</p>
            </div>
          ))}
        </div>
      )}
    </div>
  );
});
