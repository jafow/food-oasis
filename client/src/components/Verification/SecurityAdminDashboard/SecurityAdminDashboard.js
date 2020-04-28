import React, { useState, useEffect } from 'react'
import SecurityTable from './SecurityTable' 
import { makeStyles } from "@material-ui/styles";
import Typography from '@material-ui/core/Typography';
import Container from "@material-ui/core/Container";
import Grid from "@material-ui/core/Grid";
import { TextField } from '@material-ui/core';
import * as accountService from "../../../services/account-service";

const useStyles = makeStyles({
  root: {
    textAlign: "center",
    padding: "2rem",
  },
  textInput: {
    marginBottom: 10
  }
});

function SecurityAdminDashboard() {
  const [acc, setAcc] = useState([])

  const classes = useStyles();

  useEffect(() => {
    const fetchData = async () => {
      try {
        const account = await accountService.getAll()
        setAcc(account.data)
      } catch(err) {
        console.log(err)
      }
    }
    fetchData()
  }, [])

  return (
    <Container maxWidth="lg" className={classes.root}>
      <Typography variant="h4">Security Roles</Typography>
      <Typography variant="h6">Grant or Revoke Admin Permissions</Typography>
      <TextField
        variant="outlined"
        margin="none"
        placeholder="Find"
        size="small"
        className={classes.textInput}
      />
      <SecurityTable accounts={acc}/>
    </Container>
  )
}

export default SecurityAdminDashboard