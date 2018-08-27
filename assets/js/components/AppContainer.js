import React, { Component } from 'react'
import { gtfsr_channel } from '../socket'

import UpdateStatusBar from './UpdateStatusBar'
import VehicleUpdates from './VehicleUpdates'

export default class AppContainer extends Component {

  constructor() {
    super()

    this.state = {
      connected: false,
      timestamp: null,
      updates: []
    }

    gtfsr_channel.join()
      .receive('ok', resp => {
        this.setState({...this.state, connected: true})
      })

    gtfsr_channel.on('new_update', payload => {
      this.setState((prevState, _props) => {
        let { body } = payload
        if (prevState && body.timestamp > prevState.timestamp) {
          return Object.assign({}, prevState, body)
        }
      })
    })
  }

  render() {
    let { timestamp, connected } = this.state
    let { vehicle: vehicle_updates, trip: trip_updates } = this.state.updates

    return (
      <div>
        <div className='row'>
          <UpdateStatusBar timestamp={timestamp} connected={connected} />
        </div>
        <div className='row'>
          <VehicleUpdates updates={vehicle_updates} />
        </div>
      </div>
    )
  }
}
