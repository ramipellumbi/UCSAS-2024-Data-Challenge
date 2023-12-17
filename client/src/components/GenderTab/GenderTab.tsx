import { Tabs } from '@mantine/core';
import styles from './GenderTab.module.css';
import { Dispatch, SetStateAction } from 'react';
import { Gender } from '@/constants';

type GenderTabProps = {
  activeTab: Gender;
  setActiveTab: Dispatch<SetStateAction<Gender>>;
};

export function GenderTab({ activeTab, setActiveTab }: GenderTabProps) {
  return (
    <div className={styles.tabsContainer}>
      <Tabs value={activeTab} onChange={(v) => setActiveTab(v as Gender)}>
        <Tabs.List className={styles.tabsList}>
          <Tabs.Tab
            value="m"
            key="Men"
            className={activeTab === 'm' ? styles.tabActive : styles.tab}
          >
            Men
          </Tabs.Tab>
          <Tabs.Tab
            value="w"
            key="Women"
            className={activeTab === 'w' ? styles.tabActive : styles.tab}
          >
            Women
          </Tabs.Tab>
        </Tabs.List>
      </Tabs>
    </div>
  );
}
