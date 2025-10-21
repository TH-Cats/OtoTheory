"use client";
import React from "react";

interface ErrorBoundaryState {
  err?: any;
}

interface ErrorBoundaryProps {
  children: React.ReactNode;
}

export default class ErrorBoundary extends React.Component<ErrorBoundaryProps, ErrorBoundaryState> {
  state: ErrorBoundaryState = { err: undefined };

  static getDerivedStateFromError(err: any): ErrorBoundaryState {
    return { err };
  }

  render() {
    if (this.state.err) {
      return (
        <div style={{ 
          whiteSpace: 'pre-wrap', 
          padding: '12px', 
          background: '#fee', 
          border: '1px solid #f00',
          margin: '10px',
          borderRadius: '4px',
          fontFamily: 'monospace',
          fontSize: '12px'
        }}>
          <h3>Error Boundary Caught:</h3>
          <pre>{String(this.state.err?.stack || this.state.err)}</pre>
        </div>
      );
    }
    return this.props.children;
  }
}
