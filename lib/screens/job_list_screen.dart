import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/job_provider.dart';
import '../providers/user_provider.dart';
import '../models/job_model.dart';
import 'job_detail_screen.dart';
import 'add_job_screen.dart';
import 'login_screen.dart';

class JobListScreen extends StatefulWidget {
  const JobListScreen({Key? key}) : super(key: key);

  @override
  _JobListScreenState createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch jobs when screen loads
    _initializeJobs();
  }

  Future<void> _initializeJobs() async {
    // Get the current user
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final jobProvider = Provider.of<JobProvider>(context, listen: false);

    // Add demo jobs if needed (only if user is a recruiter)
    if (userProvider.isRecruiter && userProvider.currentUser != null) {
      await jobProvider.addDemoJobs(userProvider.currentUser!.id);
    } else {
      await jobProvider.fetchJobs();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Jobs'),
        actions: [
          Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              return IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await userProvider.signOut();
                  // Navigate back to login screen
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<JobProvider>(
        builder: (context, jobProvider, child) {
          if (jobProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (jobProvider.jobs.isEmpty) {
            return const Center(child: Text('No jobs found'));
          }

          return ListView.builder(
            itemCount: jobProvider.jobs.length,
            itemBuilder: (context, index) {
              final job = jobProvider.jobs[index];
              return _buildJobCard(context, job);
            },
          );
        },
      ),
      floatingActionButton: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          // Only show add job button for recruiters
          if (userProvider.isRecruiter) {
            return FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddJobScreen(),
                  ),
                );
              },
              child: const Icon(Icons.add),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildJobCard(BuildContext context, Job job) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: () {
          // Select job and navigate to detail
          Provider.of<JobProvider>(context, listen: false).selectJob(job);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JobDetailScreen(jobId: job.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                job.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                job.company,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16),
                  const SizedBox(width: 4),
                  Text(job.location),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                job.description.length > 100
                    ? '${job.description.substring(0, 100)}...'
                    : job.description,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}