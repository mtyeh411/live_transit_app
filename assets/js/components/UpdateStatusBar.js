import React from 'react'

const timestampDisplayOptions = {
  year: 'numeric',
  month: 'short',
  day: 'numeric',
  hour: 'numeric',
  minute: 'numeric'
}

const locale = 'en-US'

const UpdateStatusBar = ({
  connected,
  timestamp
}) => {
  return (
    <div>
      <div className='col-xs-6 text-left'>
        Status:
        { connected ? 'Connected' : 'Not Connected' }
      </div>
      <div className={`col-xs-6 text-right ${timestamp ? '' : 'hidden'}`}>
        Last updated:
        {new Date(timestamp * 1000).toLocaleDateString(locale, timestampDisplayOptions)}
      </div>
    </div>
  )
}

export default UpdateStatusBar
