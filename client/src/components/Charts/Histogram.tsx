import { Chart as ChartJS, registerables } from 'chart.js';
ChartJS.register(...registerables);
import { Bar } from 'react-chartjs-2';

type Data = {
  country: string;
  medal: string;
  name: string;
  apparatus: string;
};

const processTeamData = (data: Data[]) => {
  const teamData = data.reduce((acc, { country, medal }) => {
    if (!acc[country]) {
      acc[country] = { Gold: 0, Silver: 0, Bronze: 0 };
    }
    acc[country][medal]++;
    return acc;
  }, Object.create(null));
  return teamData;
};

const processIndividualData = (data: Data[]) => {
  const teamData = data.reduce((acc, { name, medal, country }) => {
    const key = `${name} (${country})`;
    if (!acc[key]) {
      acc[key] = { Gold: 0, Silver: 0, Bronze: 0 };
    }
    acc[key][medal]++;
    return acc;
  }, Object.create(null));
  return teamData;
};

const processApparatusData = (data: Data[]) => {
  const teamData = data.reduce((acc, { name, country, medal }) => {
    const key = `${name} (${country})`;
    if (!acc[key]) {
      acc[key] = { Gold: 0, Silver: 0, Bronze: 0 };
    }
    acc[key][medal]++;
    return acc;
  }, Object.create(null));
  return teamData;
};

const options = {
  responsive: true,
  maintainAspectRatio: false,
  scales: {
    x: {
      grid: {
        color: 'rgba(0, 0, 0, 0.1)',
      },
      ticks: {
        color: '#4A4A4A',
      },
    },
    y: {
      grid: {
        color: 'rgba(0, 0, 0, 0.1)',
      },
      ticks: {
        color: '#4A4A4A',
      },
    },
  },
  plugins: {
    title: {
      text: '',
      display: true,
      font: {
        size: 20,
      },
    },
    legend: {
      position: 'top',
      labels: {
        font: {
          size: 14,
        },
      },
    },
  },
} as const;

export function Histogram({
  data,
  type,
  title,
}: {
  data: Data[];
  type: 'team' | 'individual' | 'apparatus';
  title?: string;
}) {
  const processedData = (() => {
    if (type === 'individual') {
      return processIndividualData(data);
    }
    if (type === 'team') {
      return processTeamData(data);
    }

    return processApparatusData(data);
  })();
  const keys = Object.keys(processedData).sort();
  const goldCounts = keys.map((country) => processedData[country].Gold);
  const silverCounts = keys.map((country) => processedData[country].Silver);
  const bronzeCounts = keys.map((country) => processedData[country].Bronze);

  const chartData = {
    labels: keys,
    datasets: [
      {
        label: 'Gold Medals',
        data: goldCounts,
        backgroundColor: 'gold',
      },
      {
        label: 'Silver Medals',
        data: silverCounts,
        backgroundColor: 'silver',
      },
      {
        label: 'Bronze Medals',
        data: bronzeCounts,
        backgroundColor: '#cd7f32',
      },
    ],
  };

  const text = (() => {
    if (title) {
      return title;
    }

    if (type === 'individual') {
      return 'Individual Medal Counts';
    }
    if (type === 'team') {
      return 'Team Medal Counts';
    }

    return 'Apparatus Medal Counts';
  })();

  const newOptions = {
    ...options,
    plugins: {
      ...options.plugins,
      title: {
        ...options.plugins.title,
        text: text,
      },
    },
  };

  return (
    <div
      style={{
        backgroundColor: 'white',
        marginTop: '5px',
        marginBottom: '5px',
      }}
    >
      <Bar data={chartData} options={newOptions} />
    </div>
  );
}
