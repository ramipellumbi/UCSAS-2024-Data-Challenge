/**
 * Client rendered page
 */

'use client';

import { GenderTab, TeamSelectedView, TeamSelectionDrawer } from '@/components';
import { Gender } from '@/constants';
import { Button, Tabs } from '@mantine/core';
import { useDisclosure } from '@mantine/hooks';
import React, { useCallback, useState } from 'react';

export function HomeClient() {
  const disclosure = useDisclosure(true);

  const [teamData, setTeamData] = useState<{
    [gender in Gender]: string[];
  }>({ m: [], w: [] });
  const [activeTab, setActiveTab] = useState<Gender>('m');

  const selectedTeam = teamData[activeTab];
  const setSelectedTeam = useCallback(
    (team: string[]) => {
      setTeamData({ ...teamData, [activeTab]: team });
    },
    [activeTab, teamData, setTeamData]
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
    </>
  );
}
