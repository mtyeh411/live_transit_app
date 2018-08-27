import React, { Component } from 'react'
import { gtfsr_channel } from '../socket'

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
    let { timestamp, updates } = this.state
    return (
      <div>
        {timestamp && Date(timestamp)} {updates}
      </div>
    )
  }
}
