'use client';

import { useState } from 'react';

import { Box, Button, Center, LoadingOverlay, Pagination, Text, Tooltip } from '@mantine/core';
import { useDisclosure, useLocalStorage } from '@mantine/hooks';
import { useQuery } from '@tanstack/react-query';
import axios from 'axios';
import Link from 'next/link';

import styles from '../Home.module.css';

import {
  ApparatusCard,
  DetailsModal,
  GenderTab,
  Histogram,
  TeamSelectedView,
  TeamSelectionDrawer,
} from '@/components';
import { Apparatus, APPARATUSES, Gender } from '@/constants';

const fetchData = async (gender: Gender, team: string[]) => {
  const response = await axios.get<{
    usa_samples: { name: string; apparatus: string; gender: string; run: number; sample: number }[];
    other_options: {
      name: string;
      country: string;
    }[];
    other_samples: {
      name: string;
      apparatus: string;
      country: string;
      gender: string;
      run: number;
      sample: number;
    }[];
    team_medalists: {
      country: string;
      medal: string;
      run: number;
      sample: number;
      count: number;
    }[];
    apparatus_medalists: {
      apparatus: string;
      name: string;
      medal: string;
      run: number;
      sample: number;
      count: number;
    }[];
    individual_aa_medalists: {
      name: string;
      medal: string;
      run: number;
      sample: number;
      count: number;
    }[];
    total_samples_per_run: [number];
    total_runs_with_team: [number];
  }>('/explore', {
    params: {
      gender_t: gender,
      team,
    },
  });

  return response;
};

export default function Explorer() {
  const disclosure = useDisclosure(false);

  const [activeRun, setActiveRun] = useState(1);
  const [activeSample, setActiveSample] = useState(1);
  const [isDetailsModalOpen, setIsDetailsModalOpen] = useState(false);

  const [teamM, setTeamM] = useLocalStorage<string[]>({ defaultValue: [], key: 'teamM' });
  const [teamW, setTeamW] = useLocalStorage<string[]>({ defaultValue: [], key: 'teamW' });
  const [activeTab, setActiveTab] = useLocalStorage<Gender>({
    defaultValue: 'm',
    key: 'activeTab',
  });

  const selectedTeam = activeTab === 'm' ? teamM : teamW;
  const teamButtonLabel = selectedTeam.length === 5 ? 'Change Team' : 'Select Team';

  const query = useQuery({
    queryKey: [activeTab, ...selectedTeam],
    queryFn: () => fetchData(activeTab, selectedTeam),
    enabled: selectedTeam.length === 5,
  });

  const data = query.data?.data;
  const apparatusSamples = data?.usa_samples
    .filter((v) => {
      return v.run === activeRun && v.sample === activeSample && v.gender === activeTab;
    })
    .reduce((obj, curr) => {
      if (!obj[curr.apparatus]) {
        obj[curr.apparatus] = [];
      }

      obj[curr.apparatus].push(curr.name);
      return obj;
    }, Object.create(null));
  const otherSamples = data?.other_samples
    .filter((v) => {
      return v.run === activeRun && v.sample === activeSample && v.gender === activeTab;
    })
    .reduce((obj, curr) => {
      if (!obj[curr.apparatus]) {
        obj[curr.apparatus] = {};
      }

      if (!obj[curr.apparatus][curr.country]) {
        obj[curr.apparatus][curr.country] = [];
      }

      obj[curr.apparatus][curr.country].push(curr.name);
      return obj;
    }, Object.create(null));

  const teamMedalists = data?.team_medalists.filter((v) => {
    return v.run === activeRun && v.sample === activeSample;
  });
  const apparatusMedalists = data?.apparatus_medalists.filter((v) => {
    return v.run === activeRun && v.sample === activeSample;
  });
  const individualAAMedalists = data?.individual_aa_medalists.filter((v) => {
    return v.run === activeRun && v.sample === activeSample;
  });

  return (
    <Box>
      <LoadingOverlay
        visible={query.isFetching}
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

      {!data || data.total_runs_with_team[0] === 0 || data.total_samples_per_run[0] === 0 ? (
        <Center style={{ height: '100%', marginTop: '50px' }}>
          <div>
            <Text fw={500} size="md" mb="md">
              No Simulations for Selected Team Yet
            </Text>
            <Link href="/" passHref>
              <Button
                variant="filled"
                color="dark"
                style={{ backgroundColor: '#005f73', color: 'white' }}
              >
                Go to Simulation Runner
              </Button>
            </Link>
          </div>
        </Center>
      ) : (
        <>
          {data.total_runs_with_team[0] > 1 && (
            <>
              <div
                style={{
                  display: 'flex',
                  justifyContent: 'center',
                  alignItems: 'center',
                  marginTop: '25px',
                }}
              >
                <Text fw={500} size="md">
                  Simulations with Team
                </Text>
              </div>
              <div
                style={{
                  display: 'flex',
                  justifyContent: 'center',
                  alignItems: 'center',
                  marginTop: '5px',
                }}
              >
                <Pagination
                  total={data.total_runs_with_team[0]}
                  value={activeRun}
                  onChange={setActiveRun}
                />
              </div>
            </>
          )}

          {data?.other_samples && data?.other_options && (
            <DetailsModal
              teams={data?.other_options as any}
              open={isDetailsModalOpen}
              onClose={() => setIsDetailsModalOpen(false)}
              data={data?.other_samples.filter(
                (v) => v.run === activeRun && v.sample === activeSample && v.gender === activeTab
              )}
            />
          )}

          <div
            style={{
              display: 'flex',
              justifyContent: 'center',
              alignItems: 'center',
              marginTop: '25px',
            }}
          >
            <Text fw={500} size="md">
              Apparatus Sample
            </Text>
          </div>

          <div
            style={{
              display: 'flex',
              justifyContent: 'center',
              alignItems: 'center',
              marginTop: '5px',
            }}
          >
            <Pagination
              total={data.total_samples_per_run[0]}
              value={activeSample}
              onChange={setActiveSample}
            />
          </div>

          {apparatusSamples && (
            <div
              style={{
                display: 'flex',
                flexWrap: 'wrap',
                gap: '20px',
                justifyContent: 'center',
                marginTop: '20px',
                marginBottom: '20px',
              }}
            >
              {Object.keys(apparatusSamples).map((value) => (
                <ApparatusCard
                  key={value}
                  possibleSelections={apparatusSamples[value]}
                  apparatus={value as Apparatus}
                  team={selectedTeam}
                  selectedMembers={apparatusSamples[value]}
                />
              ))}
            </div>
          )}

          <Tooltip label={'View the Team allocations behind these simulations'}>
            <Button onClick={() => setIsDetailsModalOpen(true)} className={styles.floatingButton}>
              View Detail
            </Button>
          </Tooltip>

          {individualAAMedalists && individualAAMedalists.length > 0 && (
            <Histogram data={individualAAMedalists as any} type={'individual'} />
          )}
          {teamMedalists && teamMedalists.length > 0 && (
            <Histogram data={teamMedalists as any} type={'team'} />
          )}
          {apparatusMedalists &&
            apparatusMedalists.length > 0 &&
            APPARATUSES[activeTab].map((apparatus) => (
              <Histogram
                key={apparatus}
                data={apparatusMedalists.filter((v) => v.apparatus === apparatus) as any}
                type={'apparatus'}
                title={apparatus}
              />
            ))}
        </>
      )}

      <TeamSelectionDrawer
        gender={activeTab}
        disclosure={disclosure}
        selectedTeam={selectedTeam}
        setSelectedTeam={activeTab === 'm' ? setTeamM : setTeamW}
      />
    </Box>
  );
}
