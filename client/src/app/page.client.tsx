'use client';

import React, { Dispatch, SetStateAction, useCallback, useEffect, useRef, useState } from 'react';

import { Box, Button, LoadingOverlay } from '@mantine/core';
import { useDisclosure, useLocalStorage } from '@mantine/hooks';

import styles from './Home.module.css';

import { ApparatusCard, GenderTab, TeamSelectedView, TeamSelectionDrawer } from '@/components';
import { APPARATUSES, Gender } from '@/constants';
import { useMutation } from '@tanstack/react-query';
import axios from 'axios';
import { getCombinations } from '../combinations';
import { loadJSON } from '@/loaders';

export function HomeClient() {
  const disclosure = useDisclosure(false);

  const [teamM, setTeamM] = useLocalStorage<string[]>({ defaultValue: [], key: 'teamM' });
  const [teamW, setTeamW] = useLocalStorage<string[]>({ defaultValue: [], key: 'teamW' });
  const [activeTab, setActiveTab] = useLocalStorage<Gender>({
    defaultValue: 'm',
    key: 'activeTab',
  });
  const [validSelections, setValidSelections] = useState<{ [key: string]: string[] } | null>(null);

  const prevActiveTab = useRef(activeTab);
  const prevTeamM = useRef(teamM);
  const prevTeamW = useRef(teamW);

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

  const apparatusSettersMapMen = {
    FX: setApparatusFXM,
    PH: setApparatusPHM,
    SR: setApparatusSRM,
    VT: setApparatusVTM,
    PB: setApparatusPBM,
    HB: setApparatusHBM,
  };

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

  const apparatusSettersMapWomen = {
    VT: setApparatusVTW,
    UB: setApparatusUBW,
    BB: setApparatusBBW,
    FX: setApparatusFXW,
  };

  useEffect(() => {
    const loadPossibleSelections = async () => {
      const json = await loadJSON('apparatus_names.json');
      const apparatuses = APPARATUSES[activeTab];

      const selections = apparatuses.reduce((acc, apparatus) => {
        const key = `${apparatus}.${activeTab}`;
        const names = processJSON(json, key);

        acc[key] = names;
        return acc;
      }, Object.create(null));

      setValidSelections(selections);
    };

    loadPossibleSelections();
  }, [activeTab, setValidSelections]);

  useEffect(() => {
    // Check if both tab and team have changed
    const isTeamChanged =
      (activeTab === 'm' && teamM !== prevTeamM.current) ||
      (activeTab === 'w' && teamW !== prevTeamW.current);

    if (isTeamChanged) {
      const setters = activeTab === 'm' ? apparatusSettersMapMen : apparatusSettersMapWomen;
      Object.values(setters).forEach((setter) => setter([]));
    }

    // Update previous values
    prevActiveTab.current = activeTab;
    prevTeamM.current = teamM;
    prevTeamW.current = teamW;
  }, [teamM, teamW, activeTab]);

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
      const updatedTeam = apparatusTeam.includes(member)
        ? apparatusTeam.filter((m) => m !== member)
        : [...apparatusTeam, member];

      if (updatedTeam.length > 4) {
        return;
      }
      setApparatus(updatedTeam);
    };

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

  const handleClearAssignments = useCallback(() => {
    const setters = activeTab === 'm' ? apparatusSettersMapMen : apparatusSettersMapWomen;
    Object.values(setters).forEach((setter) => setter([]));
  }, [activeTab, apparatusSettersMapMen, apparatusSettersMapWomen]);

  const handleRandomAssignments = useCallback(() => {
    const combinations = getCombinations(selectedTeam, 4);
    const setters = activeTab === 'm' ? apparatusSettersMapMen : apparatusSettersMapWomen;

    for (const apparatus of APPARATUSES[activeTab]) {
      const validNames = validSelections?.[`${apparatus}.${activeTab}`] ?? [];
      const setter = setters[apparatus as keyof typeof setters];
      let index = Math.floor(Math.random() * combinations.length);
      let count = 0;
      while (!combinations[index].every((member) => validNames.includes(member))) {
        index = Math.floor(Math.random() * combinations.length);
        count += 1;

        if (count > 100) {
          break;
        }
      }
      if (count > 100) {
        alert(
          'No valid combinations found for this team based on the data points. Select another team and try again.'
        );
        return;
      } else {
        setter(combinations[index]);
      }
    }
  }, [selectedTeam, validSelections, activeTab, apparatusSettersMapMen, apparatusSettersMapWomen]);

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
      {selectedTeam.length == 5 && (
        <div
          style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', gap: '20px' }}
        >
          <Button
            style={{ margin: '10px 0', backgroundColor: '#493E80', color: 'white' }}
            onClick={handleClearAssignments}
          >
            Clear Assignments
          </Button>
          <Button
            style={{ margin: '10px 0', backgroundColor: '#005f73', color: 'white' }}
            onClick={handleRandomAssignments}
          >
            Randomly assign team
          </Button>
        </div>
      )}

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
            possibleSelections={validSelections?.['FX.m'] ?? []}
            apparatus="FX"
            team={teamM}
            selectedMembers={apparatusFXM}
            onSelect={handleSelectMemberForApparatus(setApparatusFXM, apparatusFXM)}
          />
          <ApparatusCard
            possibleSelections={validSelections?.['PH.m'] ?? []}
            apparatus="PH"
            team={teamM}
            selectedMembers={apparatusPHM}
            onSelect={handleSelectMemberForApparatus(setApparatusPHM, apparatusPHM)}
          />
          <ApparatusCard
            possibleSelections={validSelections?.['SR.m'] ?? []}
            apparatus="SR"
            team={teamM}
            selectedMembers={apparatusSRM}
            onSelect={handleSelectMemberForApparatus(setApparatusSRM, apparatusSRM)}
          />
          <ApparatusCard
            possibleSelections={validSelections?.['VT.m'] ?? []}
            apparatus="VT"
            team={teamM}
            selectedMembers={apparatusVTM}
            onSelect={handleSelectMemberForApparatus(setApparatusVTM, apparatusVTM)}
          />
          <ApparatusCard
            possibleSelections={validSelections?.['PB.m'] ?? []}
            apparatus="PB"
            team={teamM}
            selectedMembers={apparatusPBM}
            onSelect={handleSelectMemberForApparatus(setApparatusPBM, apparatusPBM)}
          />
          <ApparatusCard
            possibleSelections={validSelections?.['HB.m'] ?? []}
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
            possibleSelections={validSelections?.['BB.w'] ?? []}
            apparatus="BB"
            team={teamW}
            selectedMembers={apparatusBBW}
            onSelect={handleSelectMemberForApparatus(setApparatusBBW, apparatusBBW)}
          />
          <ApparatusCard
            possibleSelections={validSelections?.['FX.w'] ?? []}
            apparatus="FX"
            team={teamW}
            selectedMembers={apparatusFXW}
            onSelect={handleSelectMemberForApparatus(setApparatusFXW, apparatusFXW)}
          />
          <ApparatusCard
            possibleSelections={validSelections?.['UB.w'] ?? []}
            apparatus="UB"
            team={teamW}
            selectedMembers={apparatusUBW}
            onSelect={handleSelectMemberForApparatus(setApparatusUBW, apparatusUBW)}
          />
          <ApparatusCard
            possibleSelections={validSelections?.['VT.w'] ?? []}
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

const processJSON = (json: unknown, key: string): string[] => {
  if (typeof json !== 'object' || json === null) {
    throw new Error('Invalid JSON');
  }

  if (!(key in json)) {
    throw new Error('Invalid JSON');
  }

  const names = (json as any)[key] as string[];
  if (!Array.isArray(names)) {
    throw new Error('Invalid JSON');
  }

  return names;
};
