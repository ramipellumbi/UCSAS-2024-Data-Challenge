import { memo } from 'react';
import { Text } from '@mantine/core';
import styles from './ApparatusCard.module.css';
import { Apparatus } from '@/constants';

type ApparatusCardProps = {
  apparatus: Apparatus;
  team: string[];
  selectedMembers: string[];
  onSelect: (member: string) => void;
};

export const ApparatusCard = memo(function ApparatusCard({
  apparatus,
  team,
  selectedMembers,
  onSelect,
}: ApparatusCardProps) {
  const isComplete = selectedMembers.length === 4;
  const statusIcon = isComplete ? '✅' : '❌';
  const statusColor = isComplete ? 'green' : 'red';

  return (
    <div className={styles.apparatusCard}>
      <div style={{ display: 'flex', alignItems: 'center' }}>
        <h3 style={{ marginRight: '10px' }}>{apparatus}</h3>
        <span style={{ color: statusColor }}>{statusIcon}</span>
      </div>
      <div className={styles.cardContainer}>
        {team.map((member) => (
          <MemberCard
            key={member}
            isComplete={isComplete}
            member={member}
            isSelected={selectedMembers.includes(member)}
            onClick={() => onSelect(member)}
          />
        ))}
      </div>
    </div>
  );
});

type MemberCardProps = {
  member: string;
  isComplete: boolean;
  isSelected: boolean;
  onClick: () => void;
};

const MemberCard = memo(function MemberCard({
  member,
  isComplete,
  isSelected,
  onClick,
}: MemberCardProps) {
  return (
    <div
      className={`${styles.memberCard} ${isSelected ? styles.memberCardSelected : ''}`}
      onClick={onClick}
    >
      <Text
        style={{
          color: !isComplete || isSelected ? 'inherit' : 'gray',
        }}
      >
        {member}
      </Text>
    </div>
  );
});
