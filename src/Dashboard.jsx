import { Container, Section, Grid, Card , Separator } from '@gumgum/resonance'

function Dashboard() {
  return (
   <Container size="lg">
      <Section size="md">
        <Grid columns="3" gap="4">
          <Card>Revenue</Card>
          <Card>Users</Card>
          <Card>Growth</Card>
        </Grid>
      </Section>
    </Container>
  )
}

export default Dashboard