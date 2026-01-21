import { useAuth } from '../hooks/useAuth'

export default function Dashboard() {
  const { user, signOut } = useAuth()

  const handleSignOut = async () => {
    await signOut()
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <nav className="bg-white shadow">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4 flex justify-between items-center">
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Simple CRM</h1>
            <p className="text-sm text-gray-500">Cross-Border Ecommerce</p>
          </div>
          <div className="flex items-center gap-4">
            <div className="text-right">
              <p className="text-sm font-medium text-gray-700">{user?.email}</p>
              <p className="text-xs text-gray-500">Phase 0: Setup Complete</p>
            </div>
            <button
              onClick={handleSignOut}
              className="px-4 py-2 bg-gray-200 hover:bg-gray-300 text-gray-700 rounded-md text-sm font-medium transition-colors"
            >
              Sign out
            </button>
          </div>
        </div>
      </nav>

      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="bg-white rounded-lg shadow p-6 mb-6">
          <h2 className="text-2xl font-bold text-gray-900 mb-2">
            Welcome to Simple CRM
          </h2>
          <p className="text-gray-600 mb-4">
            Phase 0: Project Setup is complete! The development environment is ready for feature implementation.
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-6">
          <div className="bg-white rounded-lg shadow p-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-2">✓ Supabase</h3>
            <p className="text-sm text-gray-600">Database, Auth, and API configured</p>
          </div>
          <div className="bg-white rounded-lg shadow p-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-2">✓ Frontend</h3>
            <p className="text-sm text-gray-600">React + TypeScript + Tailwind CSS</p>
          </div>
          <div className="bg-white rounded-lg shadow p-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-2">✓ Authentication</h3>
            <p className="text-sm text-gray-600">Login and protected routes working</p>
          </div>
        </div>

        <div className="bg-blue-50 border border-blue-200 rounded-lg p-6">
          <h3 className="text-lg font-semibold text-blue-900 mb-2">Next Steps (Phase 1)</h3>
          <ul className="list-disc list-inside text-blue-800 space-y-1">
            <li>Customer management UI (list, detail, create, edit)</li>
            <li>Real-time customer updates</li>
            <li>Basic filtering and search</li>
            <li>Customer tags and segmentation</li>
          </ul>
        </div>
      </main>
    </div>
  )
}
