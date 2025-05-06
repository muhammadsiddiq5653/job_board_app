// lib/screens/job_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/job_provider.dart';
import '../providers/user_provider.dart';
import '../models/job_model.dart';
import '../widgets/animated_job_card.dart';
import 'job_detail_screen.dart';
import 'add_job_screen.dart';
import 'login_screen.dart';
import 'my_applications_screen.dart';

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
              // Show applications button for job seekers
              if (userProvider.currentUser != null &&
                  !userProvider.isRecruiter) {
                return IconButton(
                  icon: const Icon(Icons.history),
                  tooltip: 'My Applications',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MyApplicationsScreen(),
                      ),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
          Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              return IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Logout',
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
              return AnimatedJobCard(
                job: job,
                index: index,
                onTap: () {
                  // Select job and navigate to detail
                  jobProvider.selectJob(job);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JobDetailScreen(jobId: job.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          // Debug log to verify role detection
          print('Current user role is recruiter: ${userProvider.isRecruiter}');

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
}
