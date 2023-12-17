import styles from './TeamSelectedView.module.css'; // Adjust the path according to your file structure

type TeamSelectedViewProps = {
  selectedTeam: string[];
};

export function TeamSelectedView({ selectedTeam }: TeamSelectedViewProps) {
  return (
    <>
      {selectedTeam.length > 0 && (
        <div style={{ display: 'flex', flexWrap: 'wrap', gap: '10px', marginTop: '20px' }}>
          {selectedTeam.map((member) => (
            <div key={member} className={styles.teamMemberCard}>
              <p style={{ fontWeight: 'bold', margin: 0 }}>{member}</p>
            </div>
          ))}
        </div>
      )}
    </>
  );
}
