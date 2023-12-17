'use client';

import React, { Dispatch, SetStateAction, useEffect } from 'react';

import { Box, Button, LoadingOverlay } from '@mantine/core';
import { useDisclosure, useLocalStorage } from '@mantine/hooks';

import styles from './Home.module.css';

import { ApparatusCard, GenderTab, TeamSelectedView, TeamSelectionDrawer } from '@/components';
import { Gender } from '@/constants';
import { useMutation } from '@tanstack/react-query';
import axios from 'axios';

export function HomeClient() {
  const disclosure = useDisclosure(false);

  const [teamM, setTeamM] = useLocalStorage<string[]>({ defaultValue: [], key: 'teamM' });
  const [teamW, setTeamW] = useLocalStorage<string[]>({ defaultValue: [], key: 'teamW' });

  /**
   * Keeping in an object of type { [gender]: { [apparatus]: string[] } }
   * would seem much better but it causes performance issues due to deep
   * state updates
   */

  // Men's apparatuses
  const [apparatusFXM, setApparatusFXM] = useLocalStorage<string[]>({
    defaultValue: [],
    key: 'apparatusFXM',
  });
  const [apparatusPHM, setApparatusPHM] = useLocalStorage<string[]>({
    defaultValue: [],
    key: 'apparatusPHM',
  });
  const [apparatusSRM, setApparatusSRM] = useLocalStorage<string[]>({
    defaultValue: [],
    key: 'apparatusSRM',
  });
  const [apparatusVTM, setApparatusVTM] = useLocalStorage<string[]>({
    defaultValue: [],
    key: 'apparatusVTM',
  });
  const [apparatusPBM, setApparatusPBM] = useLocalStorage<string[]>({
    defaultValue: [],
    key: 'apparatusPBM',
  });
  const [apparatusHBM, setApparatusHBM] = useLocalStorage<string[]>({
    defaultValue: [],
    key: 'apparatusHBM',
  });

  // Women's apparatuses
  const [apparatusVTW, setApparatusVTW] = useLocalStorage<string[]>({
    defaultValue: [],
    key: 'apparatusVTW',
  });
  const [apparatusUBW, setApparatusUBW] = useLocalStorage<string[]>({
    defaultValue: [],
    key: 'apparatusUBW',
  });
  const [apparatusBBW, setApparatusBBW] = useLocalStorage<string[]>({
    defaultValue: [],
    key: 'apparatusBBW',
  });
  const [apparatusFXW, setApparatusFXW] = useLocalStorage<string[]>({
    defaultValue: [],
    key: 'apparatusFXW',
  });

  const mutation = useMutation({
    mutationKey: ['simulate'],
    mutationFn: async () => {
      const body: any = {};
      if (activeTab === 'm') {
        body['gender'] = 'm';
        body['team'] = teamM;
        body['FX'] = apparatusFXM;
        body['PH'] = apparatusPHM;
        body['SR'] = apparatusSRM;
        body['VT'] = apparatusVTM;
        body['PB'] = apparatusPBM;
        body['HB'] = apparatusHBM;
      } else {
        body['gender'] = 'w';
        body['team'] = teamW;
        body['VT'] = apparatusVTW;
        body['UB'] = apparatusUBW;
        body['BB'] = apparatusBBW;
        body['FX'] = apparatusFXW;
      }
      await axios.post('/simulate', {
        body,
      });
    },
  });

  const handleSelectMemberForApparatus =
    (setApparatus: Dispatch<SetStateAction<string[]>>, apparatusTeam: string[]) =>
    (member: string) => {
      if (apparatusTeam.length === 4) {
        return;
      }
      const updatedTeam = apparatusTeam.includes(member)
        ? apparatusTeam.filter((m) => m !== member)
        : [...apparatusTeam, member];
      setApparatus(updatedTeam);
    };

  const [activeTab, setActiveTab] = useLocalStorage<Gender>({
    defaultValue: 'm',
    key: 'activeTab',
  });
  const selectedTeam = activeTab === 'm' ? teamM : teamW;
  const teamButtonLabel = selectedTeam.length === 5 ? 'Change Team' : 'Select Team';

  const areAllApparatusesComplete =
    activeTab === 'm'
      ? apparatusFXM.length === 4 &&
        apparatusPHM.length === 4 &&
        apparatusSRM.length === 4 &&
        apparatusVTM.length === 4 &&
        apparatusPBM.length === 4 &&
        apparatusHBM.length === 4
      : apparatusVTW.length === 4 &&
        apparatusUBW.length === 4 &&
        apparatusBBW.length === 4 &&
        apparatusFXW.length === 4;

  const hasSimulationResults = false;

  return (
    <Box pos="relative">
      <LoadingOverlay
        visible={mutation.isPending}
        zIndex={1000}
        overlayProps={{ radius: 'sm', blur: 2 }}
      />
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
        gender={activeTab}
        disclosure={disclosure}
        selectedTeam={selectedTeam}
        setSelectedTeam={activeTab === 'm' ? setTeamM : setTeamW}
      />

      {areAllApparatusesComplete && (
        <Button
          className={styles.floatingButton}
          onClick={async () => {
            await mutation.mutateAsync();
          }}
        >
          {hasSimulationResults ? 'View Results' : 'Simulate'}
        </Button>
      )}

      {activeTab === 'm' && teamM.length === 5 && (
        <div className={styles.apparatusContainer}>
          <ApparatusCard
            apparatus="FX"
            team={teamM}
            selectedMembers={apparatusFXM}
            onSelect={handleSelectMemberForApparatus(setApparatusFXM, apparatusFXM)}
          />
          <ApparatusCard
            apparatus="PH"
            team={teamM}
            selectedMembers={apparatusPHM}
            onSelect={handleSelectMemberForApparatus(setApparatusPHM, apparatusPHM)}
          />
          <ApparatusCard
            apparatus="SR"
            team={teamM}
            selectedMembers={apparatusSRM}
            onSelect={handleSelectMemberForApparatus(setApparatusSRM, apparatusSRM)}
          />
          <ApparatusCard
            apparatus="VT"
            team={teamM}
            selectedMembers={apparatusVTM}
            onSelect={handleSelectMemberForApparatus(setApparatusVTM, apparatusVTM)}
          />
          <ApparatusCard
            apparatus="PB"
            team={teamM}
            selectedMembers={apparatusPBM}
            onSelect={handleSelectMemberForApparatus(setApparatusPBM, apparatusPBM)}
          />
          <ApparatusCard
            apparatus="HB"
            team={teamM}
            selectedMembers={apparatusHBM}
            onSelect={handleSelectMemberForApparatus(setApparatusHBM, apparatusHBM)}
          />
        </div>
      )}

      {activeTab === 'w' && teamW.length === 5 && (
        <div className={styles.apparatusContainer}>
          <ApparatusCard
            apparatus="BB"
            team={teamW}
            selectedMembers={apparatusBBW}
            onSelect={handleSelectMemberForApparatus(setApparatusBBW, apparatusBBW)}
          />
          <ApparatusCard
            apparatus="FX"
            team={teamW}
            selectedMembers={apparatusFXW}
            onSelect={handleSelectMemberForApparatus(setApparatusFXW, apparatusFXW)}
          />
          <ApparatusCard
            apparatus="UB"
            team={teamW}
            selectedMembers={apparatusUBW}
            onSelect={handleSelectMemberForApparatus(setApparatusUBW, apparatusUBW)}
          />
          <ApparatusCard
            apparatus="VT"
            team={teamW}
            selectedMembers={apparatusVTW}
            onSelect={handleSelectMemberForApparatus(setApparatusVTW, apparatusVTW)}
          />
        </div>
      )}
    </Box>
  );
}
