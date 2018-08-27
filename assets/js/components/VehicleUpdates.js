import React from 'react'

const VehicleUpdates = ({
  updates
}) => {
  return (
    <div>
      <div className='col-xs-12'>
        Vehicle Updates:
        { updates && updates.length }
        <pre>
          { JSON.stringify(updates, null, 2) }
        </pre>
      </div>
    </div>
  )
}

export default VehicleUpdates
