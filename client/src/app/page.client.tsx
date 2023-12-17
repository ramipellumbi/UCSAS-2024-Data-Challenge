/**
 * Client rendered page
 */

'use client';

import styles from './Home.module.css';

import { ApparatusCard, GenderTab, TeamSelectedView, TeamSelectionDrawer } from '@/components';
import { Apparatuses, Gender } from '@/constants';
import { Button } from '@mantine/core';
import { useDisclosure } from '@mantine/hooks';
import React, { useCallback, useState } from 'react';

export function HomeClient() {
  const disclosure = useDisclosure(true);

  const [teamData, setTeamData] = useState<{
    [gender in Gender]: string[];
  }>({ m: [], w: [] });
  const [apparatusData, setApparatusData] = useState<{
    [gender in Gender]: {
      [apparatus in Apparatuses[gender][number]]: string[];
    };
  }>({
    m: {
      FX: [],
      PH: [],
      SR: [],
      VT: [],
      PB: [],
      HB: [],
    },
    w: {
      VT: [],
      UB: [],
      BB: [],
      FX: [],
    },
  });
  const [activeTab, setActiveTab] = useState<Gender>('m');

  const selectedTeam = teamData[activeTab];
  const apparatusTeams = apparatusData[activeTab];

  const setSelectedTeam = useCallback(
    (team: string[]) => {
      setTeamData({ ...teamData, [activeTab]: team });
    },
    [activeTab, teamData, setTeamData]
  );

  const handleSelectMemberForApparatus = useCallback(
    (apparatus: string, member: string) => {
      const currentApparatusTeam = apparatusTeams[apparatus as keyof typeof apparatusTeams];
      if (currentApparatusTeam.includes(member)) {
        // Remove the member if already selected
        setApparatusData({
          ...apparatusData,
          [activeTab]: {
            ...apparatusTeams,
            [apparatus]: currentApparatusTeam.filter((m) => m !== member),
          },
        });
      } else if (currentApparatusTeam.length < 4) {
        // Add the member if not already selected and if less than 4 members
        setApparatusData({
          ...apparatusData,
          [activeTab]: {
            ...apparatusTeams,
            [apparatus]: [...currentApparatusTeam, member],
          },
        });
      }
    },
    [apparatusTeams, apparatusData, activeTab]
  );

  const teamButtonLabel = selectedTeam.length === 5 ? 'Change Team' : 'Select Team';

  return (
    <>
      <div
        style={{
          display: 'flex',
          justifyContent: 'center',
          alignItems: 'center',
          gap: '20px',
          marginBottom: '20px',
        }}
      >
        <Button
          onClick={disclosure[1].open}
          style={{ margin: '10px 0', backgroundColor: '#005f73', color: 'white' }}
        >
          {teamButtonLabel}
        </Button>
        <GenderTab activeTab={activeTab} setActiveTab={setActiveTab} />
      </div>
      <TeamSelectedView selectedTeam={selectedTeam} />
      <TeamSelectionDrawer
        disclosure={disclosure}
        selectedTeam={selectedTeam}
        setSelectedTeam={setSelectedTeam}
      />

      {selectedTeam.length === 5 && (
        <div className={styles.apparatusContainer}>
          {Object.keys(apparatusTeams).map((apparatus) => (
            <ApparatusCard
              key={apparatus}
              apparatus={apparatus}
              team={selectedTeam}
              selectedMembers={apparatusTeams[apparatus as keyof typeof apparatusTeams]}
              onSelect={handleSelectMemberForApparatus}
            />
          ))}
        </div>
      )}
    </>
  );
}
