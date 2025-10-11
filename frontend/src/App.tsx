import React, { useEffect } from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import Layout from './components/Layout';
import DashboardPage from './pages/DashboardPage';
import TasksPage from './pages/TasksPage';
import QRScannerPage from './pages/QRScannerPage';
import SmartQRPage from './pages/SmartQRPage';
import ReportsPage from './pages/ReportsPage';
import UsersPage from './pages/UsersPage';
import LoginPage from './pages/LoginPage';
import CheckinPage from './pages/CheckinPage';
import AdminDashboardPage from './pages/AdminDashboardPage';
import EmployeeDashboardPage from './pages/EmployeeDashboardPage';
import FaceAuthSettingsPage from './pages/FaceAuthSettingsPage';
import PushNotificationsPage from './pages/PushNotificationsPage';
import CameraTest from './components/CameraTest';
import OfflineIndicator from './components/OfflineIndicator';
import PWAInstallButton from './components/PWAInstallButton';
import { useAuthStore } from './stores/authStore';
import { pwaUpdateManager } from './utils/pwaUpdate';

function App() {
  const { isAuthenticated, user } = useAuthStore();

  // Initialize PWA update manager
  useEffect(() => {
    pwaUpdateManager.initialize();
  }, []);

  // Redirect to login if not authenticated
  if (!isAuthenticated) {
    return <LoginPage />;
  }

  return (
    <div className="App">
      <Layout>
        <Routes>
          <Route path="/" element={<Navigate to="/dashboard" replace />} />
          <Route path="/dashboard" element={<DashboardPage />} />
          <Route path="/tasks" element={<TasksPage />} />
          <Route path="/qr-scan" element={<QRScannerPage />} />
          <Route path="/qr-scanner" element={<QRScannerPage />} />
          <Route path="/smart-qr" element={<SmartQRPage />} />
          <Route path="/checkin" element={<CheckinPage />} />
          <Route path="/admin-dashboard" element={<AdminDashboardPage />} />
          <Route path="/employee-dashboard" element={<EmployeeDashboardPage />} />
          <Route path="/face-auth-settings" element={<FaceAuthSettingsPage />} />
          <Route path="/push-notifications" element={<PushNotificationsPage />} />
          <Route path="/camera-test" element={<CameraTest />} />
          <Route path="/profile" element={<UsersPage />} />
          <Route path="/reports" element={<ReportsPage />} />
          <Route path="/users" element={<UsersPage />} />
          <Route path="*" element={<Navigate to="/dashboard" replace />} />
        </Routes>
      </Layout>
      
      {/* PWA Components */}
      <OfflineIndicator />
      <PWAInstallButton />
    </div>
  );
}

export default App;
