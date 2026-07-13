
import { Button, Heading, Text, Flex } from '@gumgum/resonance'

function Welcome() {
  return (
     <Flex direction="column" gap="4" align="center">
      <Heading as="h1">Welcome from Resonance!</Heading>
      <Text color="muted">Your design system is ready.</Text>
      <Button intent="primary">Get Started</Button>
    </Flex>
  )
}

export default Welcome
