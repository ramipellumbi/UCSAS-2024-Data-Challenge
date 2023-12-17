import { Title } from '@mantine/core';

import classes from './Navigation.module.css';

export function Navigation({ children }: { children: React.ReactNode }) {
  return (
    <div className={classes.navbar}>
      <div className={classes.aside}>
        <div className={classes.logo}></div>
      </div>
      <div className={classes.main}>
        <Title order={4} className={classes.title}>
          UCSAS 2024 Gymnastics Data Challenge
        </Title>
        <div className={classes.mainContent}>{children}</div>
      </div>
    </div>
  );
}
