import React, { Component } from 'react';
import { Card, Grid, Button } from 'semantic-ui-react';
import Layout from '../../components/Layout';
import Campaign from '../../ethereum/campaign';
import web3 from '../../ethereum/web3';
import ContributeForm from '../../components/ContributeForm';
import { Link } from '../../routes';

class CampaignShow extends Component {
  static async getInitialProps(props) {
    const campaign = Campaign(props.query.address);

    const summary = await campaign.methods.getSummary().call();

    return {
      address: props.query.address,
      minimumContribution: summary[0],
      balance: summary[1],
      requestsCount: summary[2],
      approversCount: summary[3],
      manager: summary[4]
    };
  }

  renderCards() {
    const {
      balance,
      manager,
      minimumContribution,
      requestsCount,
      approversCount
    } = this.props;

    const items = [
      {
        header: manager,
        meta: 'Address del creador del proyecto',
        description:
          'El presidente de la comunidad ha creado esta propuesta de instalación',
        style: { overflowWrap: 'break-word' }
      },
      {
        header: minimumContribution,
        meta: 'Inversión mínima (wei)',
        description:
          'Debes invertir esta cantidad como mínimo para poder participar'
      },
      {
        header: requestsCount,
        meta: 'Número de propuestas',
        description:
          'Una propuesta está hecha para sacar dinero del contrato. Todas las propuestas deben ser aprobadas por los participantes'
      },
      {
        header: approversCount,
        meta: 'Número de inversores',
        description:
          'Número de personas que han invertido en el proyecto'
      },
      {
        header: web3.utils.fromWei(balance, 'ether'),
        meta: 'Balance del proyecto (ether)',
        description:
          'El balance es cuánto dinero hay disponible en el contrato'
      }
    ];

    return <Card.Group items={items} />;
  }

  render() {
    return (
      <Layout>
        <h3>Información del proyecto</h3>
        <Grid>
          <Grid.Row>
            <Grid.Column width={10}>{this.renderCards()}</Grid.Column>

            <Grid.Column width={6}>
              <ContributeForm address={this.props.address} />
            </Grid.Column>
          </Grid.Row>

          <Grid.Row>
            <Grid.Column>
              <Link route={`/campaigns/${this.props.address}/requests`}>
                <a>
                  <Button primary>Ver propuestas de pago</Button>
                </a>
              </Link>
            </Grid.Column>
          </Grid.Row>
        </Grid>
      </Layout>
    );
  }
}

export default CampaignShow;
