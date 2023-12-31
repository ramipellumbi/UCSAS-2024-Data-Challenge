import { memo } from 'react';

import { Text, Tooltip } from '@mantine/core';

import styles from './ApparatusCard.module.css';

import { Apparatus } from '@/constants';

type ApparatusCardProps = {
  possibleSelections: string[];
  apparatus: Apparatus;
  team: string[];
  selectedMembers: string[];
  onSelect?: (member: string) => void;
};

export const ApparatusCard = memo(function ApparatusCard({
  possibleSelections,
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
            isClickable={possibleSelections.includes(member)}
            onClick={onSelect ? () => onSelect(member) : undefined}
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
  isClickable: boolean;
  onClick?: () => void;
};

const MemberCard = memo(function MemberCard({
  member,
  isComplete,
  isSelected,
  isClickable,
  onClick,
}: MemberCardProps) {
  const getTextColor = () => {
    if (!isClickable) {
      return 'gray';
    }

    if (isComplete && !isSelected) {
      return 'gray';
    }

    return 'inherit';
  };

  const getTooltipText = () => {
    if (!onClick) {
      return 'This is a simulation review, data is not interactable.';
    }

    if (isSelected) {
      return `Unselect ${member}`;
    }

    if (!isClickable) {
      return 'This member cannot be selected for this apparatus (no data points)';
    }

    return `Select ${member}`;
  };

  return (
    <Tooltip label={getTooltipText()}>
      <div
        className={`${styles.memberCard} ${isSelected ? styles.memberCardSelected : ''}`}
        onClick={isClickable && onClick ? onClick : undefined}
      >
        <Text
          style={{
            color: getTextColor(),
          }}
        >
          {member}
        </Text>
      </div>
    </Tooltip>
  );
});
