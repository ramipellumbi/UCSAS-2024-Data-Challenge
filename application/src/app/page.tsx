"use client";

import { useState, useEffect, Fragment } from "react";
import {
  Container,
  Typography,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  List,
  ListItem,
  ListItemText,
  Paper,
  Box,
  Chip,
  Tabs,
  Tab,
} from "@mui/material";
import { Combinations } from "@src/combinations";
import { loadCsv } from "../csv-loader";
import { areArraysEqual } from "@src/utilities";
import MedalDataDisplay from "./medals";

const colors = [
  "#D32F2F",
  "#1976D2",
  "#388E3C",
  "#FBC02D",
  "#8E24AA",
  "#F57C00",
  "#0288D1",
  "#7B1FA2",
  "#C2185B",
  "#8D6E63",
];
const nameToColorMap = new Map<string, string>();
enum TAB_VALUE {
  MEN = "m",
  WOMEN = "w",
}

export default function AssignTeams() {
  const [names, setNames] = useState<string[] | undefined>();
  const [allCombinations, setAllCombinations] = useState<
    string[][] | undefined
  >();
  const [apparatuses, setApparatuses] = useState<string[] | undefined>();
  const [data, setData] = useState<any[]>();
  const [aaData, setaaData] = useState<any[]>();
  const [apData, setApData] = useState<Record<string, Record<string, any[]>>>();

  const [gender, setGender] = useState<TAB_VALUE>(TAB_VALUE.MEN);

  // State for selected 5-member team and its 5 choose 4 combinations for each apparatus
  const [selectedTeam, setSelectedTeam] = useState<string[] | undefined>();

  const [assignments, setAssignments] = useState<
    Record<string, string[]> | undefined
  >();

  useEffect(() => {
    const loadSimulations = async () => {
      if (!selectedTeam) return;

      selectedTeam.forEach((person, idx) => {
        nameToColorMap.set(person, colors[idx]);
      });

      const csvRows = await loadCsv(
        "team_aa_medalists_simulations_results.csv"
      );
      const aaRows = await loadCsv(
        "individual_aa_medalists_simulations_results.csv"
      );
      const aparatusRows = await loadCsv(
        "apparatus_medalists_simulations_results.csv"
      );

      const apparatuses = Object.keys(csvRows.data[0])
        .filter((v) => v.includes(`_${gender}`) && !v.includes("team"))
        .map((v) => v.split("_")[0].toUpperCase());

      // for each row, get the sub team members for the usa team of 5
      const apparatusTeamsByFive = {} as any;
      csvRows.data.map((v) => {
        const akeys = Object.keys(v).filter(
          (v) => v.includes(`_${gender}`) && !v.includes("team")
        );

        const team: string = v[`team_${gender}`].split(",").sort().join(",");

        apparatusTeamsByFive[team] = akeys.reduce((p, apparatus) => {
          const app = apparatus.split("_")[0].toUpperCase();
          if (!p[app]) {
            p[app] = new Set();
          }

          v[apparatus].split(",").forEach((iv: string) => p[app].add(iv));

          return p;
        }, Object.create(null));
      });

      // convert sets to arrays
      apparatuses.forEach((apparatus) => {
        apparatusTeamsByFive[selectedTeam.join(",")][apparatus] = Array.from(
          apparatusTeamsByFive[selectedTeam.join(",")][apparatus]
        );
      });

      setAssignments(apparatusTeamsByFive[selectedTeam.join(",")]);
      setApparatuses(apparatuses);

      setData(
        csvRows.data
          .filter(
            (row) =>
              row.gender == gender &&
              areArraysEqual(row[`team_${gender}`].split(","), selectedTeam) &&
              apparatuses.every((apparatus) => {
                return areArraysEqual(
                  apparatusTeamsByFive[selectedTeam.join(",")][apparatus],
                  row[`${apparatus.toLowerCase()}_${gender}`].split(",")
                );
              })
          )
          .reduce((p, c) => {
            const key = `${c.run_simulation}${c.sample_simulation}`;

            if (!p[key]) {
              p[key] = [];
            }

            p[key].push({ country: c.country, medal: c.medal });

            return p;
          }, Object.create(null))
      );

      setApData(
        apparatuses.reduce((p, apparatus) => {
          const dataForApparatus = aparatusRows.data
            .map((row) => ({
              ...row,
              apparatus: row.apparatus.toUpperCase(),
            }))
            .filter((v) => v.apparatus == apparatus)
            .filter((row) => {
              return (
                row.gender == gender &&
                areArraysEqual(
                  row[`team_${gender}`].split(","),
                  selectedTeam
                ) &&
                apparatuses.every((apparatus) => {
                  return areArraysEqual(
                    apparatusTeamsByFive[selectedTeam.join(",")][apparatus],
                    row[`${apparatus.toLowerCase()}_${gender}`].split(",")
                  );
                })
              );
            });

          p[apparatus] = dataForApparatus.reduce((obj, row) => {
            const key = `${row.run_simulation}${row.sample_simulation}`;

            if (!obj[key]) {
              obj[key] = [];
            }

            obj[key].push(row);

            return obj;
          }, Object.create(null));

          return p;
        }, Object.create(null))
      );

      setaaData(
        aaRows.data
          .filter(
            (row) =>
              row.gender == gender &&
              areArraysEqual(row[`team_${gender}`].split(","), selectedTeam) &&
              apparatuses.every((apparatus) => {
                return areArraysEqual(
                  apparatusTeamsByFive[selectedTeam.join(",")][apparatus],
                  row[`${apparatus.toLowerCase()}_${gender}`].split(",")
                );
              })
          )
          .reduce((p, c) => {
            const key = `${c.run_simulation}${c.sample_simulation}`;

            if (!p[key]) {
              p[key] = [];
            }

            p[key].push(c);

            return p;
          }, Object.create(null))
      );
    };

    loadSimulations();
  }, [selectedTeam, gender]);

  console.log(apData);

  useEffect(() => {
    const loadData = async () => {
      const competitors = await loadCsv(
        "team_aa_medalists_simulations_results.csv"
      );

      const teams = Array.from(
        new Set(competitors.data.flatMap((v) => v[`team_${gender}`].split(",")))
      );

      setNames(teams);
    };

    loadData();
  }, [gender]);

  useEffect(() => {
    if (!names) return;
    const newCombinations = new Combinations(names, 5).compute().combinations;
    setSelectedTeam(
      newCombinations[Math.floor(Math.random() * (newCombinations.length - 1))]
    );
    setAllCombinations(newCombinations);
  }, [names]);

  const handleGlobalTeamSelection = (team: string[]) => {
    setSelectedTeam(team);
  };

  return (
    <Container
      sx={{
        display: "flex",
        flexDirection: "column",
        justifyContent: "center",
        alignItems: "center",
      }}
    >
      <Box sx={{ borderBottom: 1, borderColor: "divider", marginBottom: 10 }}>
        <Tabs
          value={gender}
          onChange={(event: React.SyntheticEvent, newValue: TAB_VALUE) => {
            setGender(newValue);
          }}
          aria-label="basic tabs example"
        >
          <Tab label="Men" value={TAB_VALUE.MEN} />
          <Tab label="Women" value={TAB_VALUE.WOMEN} />
        </Tabs>
      </Box>
      <Typography
        variant="h4"
        justifyContent={"center"}
        alignItems={"center"}
        gutterBottom
      >
        Select Team
      </Typography>

      {allCombinations && selectedTeam && selectedTeam.length > 0 && (
        <FormControl variant="outlined" fullWidth margin="normal">
          <InputLabel id="team-label">Select a team of 5</InputLabel>
          <Select
            labelId="team-label"
            value={JSON.stringify(selectedTeam)}
            onChange={(e) =>
              handleGlobalTeamSelection(JSON.parse(e.target.value))
            }
            label="Select a team of 5"
          >
            {allCombinations.map((team, index) => (
              <MenuItem key={index} value={JSON.stringify(team)}>
                {team.join(", ")}
              </MenuItem>
            ))}
          </Select>
        </FormControl>
      )}

      {selectedTeam &&
        selectedTeam.length > 0 &&
        assignments &&
        apparatuses && (
          <Paper elevation={3} style={{ padding: "20px", marginTop: "20px" }}>
            <Typography variant="h6">
              Selected Team:
              <Box display="inline-flex" gap="10px">
                {selectedTeam.map((member, index) => (
                  <Chip
                    key={index}
                    label={member}
                    style={{ backgroundColor: nameToColorMap.get(member) }}
                  />
                ))}
              </Box>
            </Typography>

            <List>
              {apparatuses.map((apparatus) => (
                <Fragment key={apparatus}>
                  <ListItem>
                    <Box
                      display="flex"
                      justifyContent="space-between"
                      alignItems="center"
                      width="100%"
                    >
                      <ListItemText primary={`Apparatus: ${apparatus}`} />
                      <Box display="flex" gap="10px">
                        {assignments[apparatus].sort().map((member, index) => (
                          <Chip
                            key={index}
                            label={member}
                            style={{
                              backgroundColor: nameToColorMap.get(member),
                            }}
                          />
                        ))}
                      </Box>
                    </Box>
                  </ListItem>
                </Fragment>
              ))}
            </List>
          </Paper>
        )}

      {data && <MedalDataDisplay data={data as any} type={"team"} />}
      {aaData && <MedalDataDisplay data={aaData as any} type={"aa"} />}
      {apData && apparatuses && (
        <>
          {apparatuses.map((apparatus) => (
            <MedalDataDisplay
              key={apparatus}
              data={apData[apparatus] as any}
              type={apparatus}
            />
          ))}
        </>
      )}
    </Container>
  );
}
